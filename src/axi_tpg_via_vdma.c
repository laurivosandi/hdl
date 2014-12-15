/*
 * VDMA.c
 *
 *  Created on: 17.3.2013
 *      Author: Ales Ruda
 *      web: www.arbot.cz
 */

#include "VDMA.h"
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

/* Register offsets */
# define OFFSET_PARK_PTR_REG              0x28
# define OFFSET_VERSION                   0x2c
# define OFFSET_VDMA_S2MM_CR                   0x30
# define OFFSET_VDMA_S2MM_SR                   0x34
# define OFFSET_VDMA_S2MM_IRQ_MASK             0x3c
# define OFFSET_VDMA_S2MM_REG_INDEX            0x44
# define OFFSET_VDMA_S2MM_VSIZE                0xa0
# define OFFSET_VDMA_S2MM_HSIZE                0xa4
# define OFFSET_VDMA_S2MM_FRMDLY_STRIDE        0xa8
# define OFFSET_VDMA_S2MM_FRAMEBUFFER1         0xac
# define OFFSET_VDMA_S2MM_FRAMEBUFFER2         0xb0
# define OFFSET_VDMA_S2MM_FRAMEBUFFER3         0xb4
# define OFFSET_VDMA_S2MM_FRAMEBUFFER4         0xb8


/* S2MM control register */
# define VDMA_S2MM_CR_RS                     0x00000001
# define VDMA_S2MM_CR_Circular_Park          0x00000002
# define VDMA_S2MM_CR_Reset                  0x00000004
# define VDMA_S2MM_CR_GenlockEn              0x00000008
# define VDMA_S2MM_CR_FrameCntEn             0x00000010
// define VDMA_S2MM_CR_RESERVED              0x00000020
// define VDMA_S2MM_CR_RESERVED              0x00000040
# define VDMA_S2MM_CR_InternalGenlock        0x00000080
# define VDMA_S2MM_CR_WrPntr                 0x00000f00
# define VDMA_S2MM_CR_FrmCtn_IrqEn           0x00001000
# define VDMA_S2MM_CR_DlyCnt_IrqEn           0x00002000
# define VDMA_S2MM_CR_ERR_IrqEn              0x00004000
# define VDMA_S2MM_CR_Repeat_En              0x00008000
//# define VDMA_S2MM_CR_InterruptFrameCount    0x00ff0000
//# define VDMA_S2MM_CR_IRQDelayCount          0xff000000

/* S2MM status register */
# define VDMA_S2MM_SR_Halted                 0x00000001  // Read-only
# define VDMA_S2MM_SR_VDMAInternalError      0x00000010  // Read or write-clear
# define VDMA_S2MM_SR_VDMASlaveError         0x00000020  // Read-only
# define VDMA_S2MM_SR_VDMADecodeError        0x00000040  // Read-only
# define VDMA_S2MM_SR_StartOfFrameEarlyError 0x00000080  // Read-only
# define VDMA_S2MM_SR_EndOfLineEarlyError    0x00000100  // Read-only
# define VDMA_S2MM_SR_StartOfFrameLateError  0x00000800  // Read-only
# define VDMA_S2MM_SR_FrameCountInterrupt    0x00001000  // Read-only
# define VDMA_S2MM_SR_DelayCountInterrupt    0x00002000  // Read-only
# define VDMA_S2MM_SR_ErrorInterrupt         0x00004000  // Read-only
# define VDMA_S2MM_SR_EndOfLineLateError     0x00008000  // Read-only
# define VDMA_S2MM_SR_FrameCount             0x00ff0000  // Read-only
# define VDMA_S2MM_SR_DelayCount             0xff000000  // Read-only

/*

 1. Write control information to the channel VDMACR register
    (Offset 0x00 for MM2S and 0x30 for S2MM) to set interrupt enables if desired,
    and set VDMACR.RS=1 to start the AXI VDMA channel running.
 2. Write valid video frame buffer start address to the channel START_ADDRESS
    register 1 to N where N equals Frame Buffers (Offset 0x5C up to 0x98 for MM2S
    and 0xAC up to 0xE8 for S2MM). Set the REG_INDEX register if required.
 3. Write a valid Frame Delay (valid only for Genlock Slave) and Stride to the
    channel FRMDLY_STRIDE register (Offset 0x58 for MM2S and 0xA8 for S2MM).
 4. Write a valid Horizontal Size to the channel HSIZE register
    (Offset 0x54 for MM2S and 0xA4 for S2MM).
 5. Write a valid Vertical Size to the channel VSIZE register
    (Offset 0x50 for MM2S and 0xA0 for S2MM). This starts the channel transferring video data.

*/

int VDMA_Init(VDMA_info *info, unsigned int baseAddr, int width, int height, int pixelLength, unsigned int fb1Addr, unsigned int fb2Addr)
{
	info->baseAddr=baseAddr;
	info->width=width;
	info->height=height;
	info->pixelLength=pixelLength;
	info->fbLength=pixelLength*width*height;
    info->vdmaHandler = open("/dev/mem", O_RDWR | O_SYNC);
    info->vdmaVirtualAddress = (unsigned int*)mmap(NULL, VDMAMapLen, PROT_READ | PROT_WRITE, MAP_SHARED, info->vdmaHandler, (off_t)info->baseAddr);
    if(info->vdmaVirtualAddress == MAP_FAILED)
    {
     perror("vdmaVirtualAddress mapping for absolute memory access failed.\n");
     return -1;
    }
    info->fb1VirtualAddress = (unsigned char*)mmap(NULL, info->fbLength, PROT_READ | PROT_WRITE, MAP_SHARED, info->vdmaHandler, (off_t)fb1Addr);
    if(info->fb1VirtualAddress == MAP_FAILED)
    {
     perror("fb1VirtualAddress mapping for absolute memory access failed.\n");
     return -2;
    }
    info->fb2VirtualAddress = (unsigned char*)mmap(NULL, info->fbLength, PROT_READ | PROT_WRITE, MAP_SHARED, info->vdmaHandler, (off_t)fb2Addr);
    if(info->fb2VirtualAddress == MAP_FAILED)
    {
     perror("fb2VirtualAddress mapping for absolute memory access failed.\n");
     return -3;
    }
/*    memset(info->fb1VirtualAddress, 0, 640*480*3);
    memset(info->fb2VirtualAddress, 0, 640*480*3);
    int j;
    printf("FB1:\n");
    for (j = 0; j < 256; j++) printf(" %02x", info->fb1VirtualAddress[j]);
    printf("\n");

    printf("FB2:\n");
    for (j = 0; j < 256; j++) printf(" %02x", info->fb2VirtualAddress[j]);
    printf("\n");

    printf("hit refresh\n");
    sleep(1); */

    
    
    
    return 0;
}

void VDMA_UnInit(VDMA_info *info)
{
    int j;
    printf("FB1:\n");
    for (j = 0; j < 256; j++) printf(" %02x", info->fb1VirtualAddress[j]);
    printf("\n");

    printf("FB2:\n");
    for (j = 0; j < 256; j++) printf(" %02x", info->fb2VirtualAddress[j]);
    printf("\n");

	VDMA_S2MM_status_dump(info);
    sleep(1);
	VDMA_S2MM_status_dump(info);
    munmap((void *)info->vdmaVirtualAddress, VDMAMapLen);
    munmap((void *)info->fb1VirtualAddress, info->fbLength);
    munmap((void *)info->fb2VirtualAddress, info->fbLength);
    close(info->vdmaHandler);
}

unsigned int VDMA_Get(VDMA_info *info, int num)
{
    return info->vdmaVirtualAddress[num>>2];

}

void VDMA_Set(VDMA_info *info, int num, unsigned int val)
{
	info->vdmaVirtualAddress[num>>2]=val;
}

void VDMA_S2MM_status_dump(VDMA_info *info) {
    int status = VDMA_Get(info, OFFSET_VDMA_S2MM_SR);
	printf("S2MM status register (%08x):", status);
    if (status & VDMA_S2MM_SR_Halted) printf(" halted");
    if (status & VDMA_S2MM_SR_VDMAInternalError) printf(" vdma-internal-error");
    if (status & VDMA_S2MM_SR_VDMASlaveError) printf(" vdma-slave-error");
    if (status & VDMA_S2MM_SR_VDMADecodeError) printf(" vdma-decode-error");
    if (status & VDMA_S2MM_SR_StartOfFrameEarlyError) printf(" start-of-frame-early-error");
    if (status & VDMA_S2MM_SR_EndOfLineEarlyError) printf(" end-of-line-early-error");
    if (status & VDMA_S2MM_SR_StartOfFrameLateError) printf(" start-of-frame-late-error");
    if (status & VDMA_S2MM_SR_FrameCountInterrupt) printf(" frame-count-interrupt");
    if (status & VDMA_S2MM_SR_DelayCountInterrupt) printf(" delay-count-interrupt");
    if (status & VDMA_S2MM_SR_ErrorInterrupt) printf(" error-interrupt");
    if (status & VDMA_S2MM_SR_EndOfLineLateError) printf(" end-of-line-late-error");
    printf(" frame-count:%d", (status & VDMA_S2MM_SR_FrameCount) >> 16);
    printf(" delay-count:%d", (status & VDMA_S2MM_SR_DelayCount) >> 24);
    printf("\n");
}

void vdma_mm2s_status_dump(VDMA_info *info) {
}



void VDMA_Start(VDMA_info *info, unsigned int adr, unsigned adr2)
{

    int j;
    printf("Vertical size: %d\n", VDMA_Get(info, OFFSET_VDMA_S2MM_VSIZE));
    int i;



    VDMA_Set(info, OFFSET_VDMA_S2MM_SR, 0xffffffff);


    VDMA_S2MM_status_dump(info);

	//VDMA_Set(info, 0x30, 64+4);  // VDMA_S2MM_DMACR: sof=tuser, reset

	// Set control register to: Internal Genlock, Reset
	VDMA_Set(info, OFFSET_VDMA_S2MM_CR, VDMA_S2MM_CR_Reset);
	
	

	// Wait for reset to finish
	while((VDMA_Get(info, OFFSET_VDMA_S2MM_CR) & VDMA_S2MM_CR_Reset)==4);
	
    printf("Vertical size: %d\n", VDMA_Get(info, OFFSET_VDMA_S2MM_VSIZE));

	printf("VDMA S2MM reset\n");

//	VDMA_Disp(info, "status ", 0x34);

	// Clear all error bits in status register	
	VDMA_Set(info, OFFSET_VDMA_S2MM_SR, 0);

	// Do not mask interrupts
	VDMA_Set(info, OFFSET_VDMA_S2MM_IRQ_MASK, 0xf);




    VDMA_S2MM_status_dump(info);

//	VDMA_Set(info, 0x30, 64+1);  // VDMA_S2MM_DMACR: sof=tuser, RS
	VDMA_Set(info, OFFSET_VDMA_S2MM_CR, 0x00004081);  // VDMA_S2MM_DMACR: sof=tuser, RS

//    int interrupt_frame_count = 2;
//    VDMA_Set(info, OFFSET_VDMA_S2MM_CR, (interrupt_frame_count << 16) | VDMA_S2MM_CR_FrmCtn_IrqEn |  VDMA_S2MM_CR_FrameCntEn | VDMA_S2MM_CR_ERR_IrqEn |  VDMA_S2MM_CR_InternalGenlock | VDMA_S2MM_CR_RS);

//    VDMA_Set(info, OFFSET_VDMA_S2MM_CR, 0x8b | VDMA_S2MM_CR_Circular_Park);

//VDMA_S2MM_CR_FrameCntEn 
	while((VDMA_Get(info, 0x30)&1)==0 || (VDMA_Get(info, 0x34)&1)==1)
	{
		VDMA_Disp(info, "status ", 0x34);
		VDMA_Disp(info, "control ", 0x30);
	}

	// Write first frame pointer
	VDMA_Set(info, OFFSET_VDMA_S2MM_FRAMEBUFFER1, adr);

	// Write second frame pointer
	VDMA_Set(info, OFFSET_VDMA_S2MM_FRAMEBUFFER2, adr2);
	
	// Extra register index, use first 16 frame pointer registers
	VDMA_Set(info, OFFSET_VDMA_S2MM_REG_INDEX, 0);

	// Write Park pointer register
	VDMA_Set(info, OFFSET_PARK_PTR_REG, 0);

    // Frame delay and stride in bytes
	VDMA_Set(info, OFFSET_VDMA_S2MM_FRMDLY_STRIDE, 640*3);

	// Write Horizontal Size in bytes
	VDMA_Set(info, OFFSET_VDMA_S2MM_HSIZE, 640*3);
	
    VDMA_S2MM_status_dump(info);
    

    printf("Horizontal size: %d (bytes)\n", VDMA_Get(info, OFFSET_VDMA_S2MM_HSIZE));
	// Write Vertical Size as number of lines
    VDMA_Set(info, OFFSET_VDMA_S2MM_VSIZE, 480);
    printf("Vertical size: %d (lines)\n", VDMA_Get(info, OFFSET_VDMA_S2MM_VSIZE));
    VDMA_S2MM_status_dump(info);
//	VDMA_Disp(info, "control ", 0x30);

//	VDMA_Get(info, OFFSET_VDMA_S2MM_FRAMEBUFFER1);

    printf("FB1: ");
    for (j = 0; j < 16; j++) printf(" %02x", info->fb1VirtualAddress[j]);
    printf("\n");

    printf("FB2: ");
    for (j = 0; j < 256; j++) printf(" %02x", info->fb2VirtualAddress[j]);
    printf("\n");
    
}

int VDMA_IsRunning(VDMA_info *info)
{

	return (VDMA_Get(info, 0x34)&1)==1;
}

int VDMA_IsDone(VDMA_info *info)
{

	int status = VDMA_Get(info, OFFSET_VDMA_S2MM_SR);
	VDMA_S2MM_status_dump(info);
	sleep(1);
	return (VDMA_Get(info, OFFSET_VDMA_S2MM_SR) & VDMA_S2MM_SR_FrameCountInterrupt)!=0;
}

void VDMA_Disp(VDMA_info *info, char *str, int num)
{
	printf("%s(%02x)=%08x\n", str, num, VDMA_Get(info, num));
}

