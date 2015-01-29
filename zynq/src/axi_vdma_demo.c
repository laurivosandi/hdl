/*
 * Triple buffering example for Xilinx VDMA v6.2 IP-core,
 * loosely based on Ales Ruda's work.
 *
 *  Created on: 17.3.2013
 *      Author: Ales Ruda
 *         web: www.arbot.cz
 *
 *  Modified on: 18.12.2014
 *       Author: Lauri Vosandi
 *          web: lauri.vosandi.com
 */

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

/* Register offsets */
#define OFFSET_PARK_PTR_REG                     0x28
#define OFFSET_VERSION                          0x2c

#define OFFSET_VDMA_MM2S_CONTROL_REGISTER       0x00
#define OFFSET_VDMA_MM2S_STATUS_REGISTER        0x04
#define OFFSET_VDMA_MM2S_VSIZE                  0x50
#define OFFSET_VDMA_MM2S_HSIZE                  0x54
#define OFFSET_VDMA_MM2S_FRMDLY_STRIDE          0x58
#define OFFSET_VDMA_MM2S_FRAMEBUFFER1           0x5c
#define OFFSET_VDMA_MM2S_FRAMEBUFFER2           0x60
#define OFFSET_VDMA_MM2S_FRAMEBUFFER3           0x64
#define OFFSET_VDMA_MM2S_FRAMEBUFFER4           0x68

#define OFFSET_VDMA_S2MM_CONTROL_REGISTER       0x30
#define OFFSET_VDMA_S2MM_STATUS_REGISTER        0x34
#define OFFSET_VDMA_S2MM_IRQ_MASK               0x3c
#define OFFSET_VDMA_S2MM_REG_INDEX              0x44
#define OFFSET_VDMA_S2MM_VSIZE                  0xa0
#define OFFSET_VDMA_S2MM_HSIZE                  0xa4
#define OFFSET_VDMA_S2MM_FRMDLY_STRIDE          0xa8
#define OFFSET_VDMA_S2MM_FRAMEBUFFER1           0xac
#define OFFSET_VDMA_S2MM_FRAMEBUFFER2           0xb0
#define OFFSET_VDMA_S2MM_FRAMEBUFFER3           0xb4
#define OFFSET_VDMA_S2MM_FRAMEBUFFER4           0xb8

/* S2MM and MM2S control register flags */
#define VDMA_CONTROL_REGISTER_START                     0x00000001
#define VDMA_CONTROL_REGISTER_CIRCULAR_PARK             0x00000002
#define VDMA_CONTROL_REGISTER_RESET                     0x00000004
#define VDMA_CONTROL_REGISTER_GENLOCK_ENABLE            0x00000008
#define VDMA_CONTROL_REGISTER_FrameCntEn                0x00000010
#define VDMA_CONTROL_REGISTER_INTERNAL_GENLOCK          0x00000080
#define VDMA_CONTROL_REGISTER_WrPntr                    0x00000f00
#define VDMA_CONTROL_REGISTER_FrmCtn_IrqEn              0x00001000
#define VDMA_CONTROL_REGISTER_DlyCnt_IrqEn              0x00002000
#define VDMA_CONTROL_REGISTER_ERR_IrqEn                 0x00004000
#define VDMA_CONTROL_REGISTER_Repeat_En                 0x00008000
#define VDMA_CONTROL_REGISTER_InterruptFrameCount       0x00ff0000
#define VDMA_CONTROL_REGISTER_IRQDelayCount             0xff000000

/* S2MM status register */
#define VDMA_STATUS_REGISTER_HALTED                     0x00000001  // Read-only
#define VDMA_STATUS_REGISTER_VDMAInternalError          0x00000010  // Read or write-clear
#define VDMA_STATUS_REGISTER_VDMASlaveError             0x00000020  // Read-only
#define VDMA_STATUS_REGISTER_VDMADecodeError            0x00000040  // Read-only
#define VDMA_STATUS_REGISTER_StartOfFrameEarlyError     0x00000080  // Read-only
#define VDMA_STATUS_REGISTER_EndOfLineEarlyError        0x00000100  // Read-only
#define VDMA_STATUS_REGISTER_StartOfFrameLateError      0x00000800  // Read-only
#define VDMA_STATUS_REGISTER_FrameCountInterrupt        0x00001000  // Read-only
#define VDMA_STATUS_REGISTER_DelayCountInterrupt        0x00002000  // Read-only
#define VDMA_STATUS_REGISTER_ErrorInterrupt             0x00004000  // Read-only
#define VDMA_STATUS_REGISTER_EndOfLineLateError         0x00008000  // Read-only
#define VDMA_STATUS_REGISTER_FrameCount                 0x00ff0000  // Read-only
#define VDMA_STATUS_REGISTER_DelayCount                 0xff000000  // Read-only

typedef struct {
    unsigned int baseAddr;
    int vdmaHandler;
    int width;
    int height;
    int pixelLength;
    int fbLength;
    unsigned int* vdmaVirtualAddress;
    unsigned char* fb1VirtualAddress;
    unsigned char* fb1PhysicalAddress;
    unsigned char* fb2VirtualAddress;
    unsigned char* fb2PhysicalAddress;
    unsigned char* fb3VirtualAddress;
    unsigned char* fb3PhysicalAddress;

    pthread_mutex_t lock;
} vdma_handle;



int vdma_setup(vdma_handle *handle, unsigned int baseAddr, int width, int height, int pixelLength, unsigned int fb1Addr, unsigned int fb2Addr, unsigned int fb3Addr) {
    handle->baseAddr=baseAddr;
    handle->width=width;
    handle->height=height;
    handle->pixelLength=pixelLength;
    handle->fbLength=pixelLength*width*height;
    handle->vdmaHandler = open("/dev/mem", O_RDWR | O_SYNC);
    handle->vdmaVirtualAddress = (unsigned int*)mmap(NULL, 65535, PROT_READ | PROT_WRITE, MAP_SHARED, handle->vdmaHandler, (off_t)handle->baseAddr);
    if(handle->vdmaVirtualAddress == MAP_FAILED) {
        perror("vdmaVirtualAddress mapping for absolute memory access failed.\n");
        return -1;
    }
    
    handle->fb1PhysicalAddress = fb1Addr;
    handle->fb1VirtualAddress = (unsigned char*)mmap(NULL, handle->fbLength, PROT_READ | PROT_WRITE, MAP_SHARED, handle->vdmaHandler, (off_t)fb1Addr);
    if(handle->fb1VirtualAddress == MAP_FAILED) {
        perror("fb1VirtualAddress mapping for absolute memory access failed.\n");
        return -2;
    }
    
    handle->fb2PhysicalAddress = fb2Addr;
    handle->fb2VirtualAddress = (unsigned char*)mmap(NULL, handle->fbLength, PROT_READ | PROT_WRITE, MAP_SHARED, handle->vdmaHandler, (off_t)fb2Addr);
    if(handle->fb2VirtualAddress == MAP_FAILED) {
        perror("fb2VirtualAddress mapping for absolute memory access failed.\n");
        return -3;
    }
    
    handle->fb3PhysicalAddress = fb3Addr;
    handle->fb3VirtualAddress = (unsigned char*)mmap(NULL, handle->fbLength, PROT_READ | PROT_WRITE, MAP_SHARED, handle->vdmaHandler, (off_t)fb3Addr);
    if(handle->fb3VirtualAddress == MAP_FAILED)
    {
     perror("fb3VirtualAddress mapping for absolute memory access failed.\n");
     return -3;
    }

    memset(handle->fb1VirtualAddress, 255, handle->width*handle->height*handle->pixelLength);
    memset(handle->fb2VirtualAddress, 255, handle->width*handle->height*handle->pixelLength);
    memset(handle->fb3VirtualAddress, 255, handle->width*handle->height*handle->pixelLength);
    return 0;
}


void vdma_halt(vdma_handle *handle) {
    vdma_set(handle, OFFSET_VDMA_S2MM_CONTROL_REGISTER, VDMA_CONTROL_REGISTER_RESET);
    vdma_set(handle, OFFSET_VDMA_MM2S_CONTROL_REGISTER, VDMA_CONTROL_REGISTER_RESET);
    munmap((void *)handle->vdmaVirtualAddress, 65535);
    munmap((void *)handle->fb1VirtualAddress, handle->fbLength);
    munmap((void *)handle->fb2VirtualAddress, handle->fbLength);
    munmap((void *)handle->fb3VirtualAddress, handle->fbLength);
    close(handle->vdmaHandler);
}

unsigned int vdma_get(vdma_handle *handle, int num) {
    return handle->vdmaVirtualAddress[num>>2];
}

void vdma_set(vdma_handle *handle, int num, unsigned int val) {
    handle->vdmaVirtualAddress[num>>2]=val;
}

void vdma_status_dump(int status) {
    if (status & VDMA_STATUS_REGISTER_HALTED) printf(" halted"); else printf("running");
    if (status & VDMA_STATUS_REGISTER_VDMAInternalError) printf(" vdma-internal-error");
    if (status & VDMA_STATUS_REGISTER_VDMASlaveError) printf(" vdma-slave-error");
    if (status & VDMA_STATUS_REGISTER_VDMADecodeError) printf(" vdma-decode-error");
    if (status & VDMA_STATUS_REGISTER_StartOfFrameEarlyError) printf(" start-of-frame-early-error");
    if (status & VDMA_STATUS_REGISTER_EndOfLineEarlyError) printf(" end-of-line-early-error");
    if (status & VDMA_STATUS_REGISTER_StartOfFrameLateError) printf(" start-of-frame-late-error");
    if (status & VDMA_STATUS_REGISTER_FrameCountInterrupt) printf(" frame-count-interrupt");
    if (status & VDMA_STATUS_REGISTER_DelayCountInterrupt) printf(" delay-count-interrupt");
    if (status & VDMA_STATUS_REGISTER_ErrorInterrupt) printf(" error-interrupt");
    if (status & VDMA_STATUS_REGISTER_EndOfLineLateError) printf(" end-of-line-late-error");
    printf(" frame-count:%d", (status & VDMA_STATUS_REGISTER_FrameCount) >> 16);
    printf(" delay-count:%d", (status & VDMA_STATUS_REGISTER_DelayCount) >> 24);
    printf("\n");
}

void vdma_s2mm_status_dump(vdma_handle *handle) {
    int status = vdma_get(handle, OFFSET_VDMA_S2MM_STATUS_REGISTER);
    printf("S2MM status register (%08x):", status);
    vdma_status_dump(status);
}

void vdma_mm2s_status_dump(vdma_handle *handle) {
    int status = vdma_get(handle, OFFSET_VDMA_MM2S_STATUS_REGISTER);
    printf("MM2S status register (%08x):", status);
    vdma_status_dump(status);
}

void vdma_start_triple_buffering(vdma_handle *handle) {
    // Reset VDMA
    vdma_set(handle, OFFSET_VDMA_S2MM_CONTROL_REGISTER, VDMA_CONTROL_REGISTER_RESET);
    vdma_set(handle, OFFSET_VDMA_MM2S_CONTROL_REGISTER, VDMA_CONTROL_REGISTER_RESET);

    // Wait for reset to finish
    while((vdma_get(handle, OFFSET_VDMA_S2MM_CONTROL_REGISTER) & VDMA_CONTROL_REGISTER_RESET)==4);
    while((vdma_get(handle, OFFSET_VDMA_MM2S_CONTROL_REGISTER) & VDMA_CONTROL_REGISTER_RESET)==4);

    // Clear all error bits in status register    
    vdma_set(handle, OFFSET_VDMA_S2MM_STATUS_REGISTER, 0);
    vdma_set(handle, OFFSET_VDMA_MM2S_STATUS_REGISTER, 0);

    // Do not mask interrupts
    vdma_set(handle, OFFSET_VDMA_S2MM_IRQ_MASK, 0xf);

    int interrupt_frame_count = 3;

    // Start both S2MM and MM2S in triple buffering mode    
    vdma_set(handle, OFFSET_VDMA_S2MM_CONTROL_REGISTER,
        (interrupt_frame_count << 16) |
        VDMA_CONTROL_REGISTER_START |
        VDMA_CONTROL_REGISTER_GENLOCK_ENABLE |
        VDMA_CONTROL_REGISTER_INTERNAL_GENLOCK |
        VDMA_CONTROL_REGISTER_CIRCULAR_PARK);
    vdma_set(handle, OFFSET_VDMA_MM2S_CONTROL_REGISTER,
        (interrupt_frame_count << 16) |
        VDMA_CONTROL_REGISTER_START |
        VDMA_CONTROL_REGISTER_GENLOCK_ENABLE |
        VDMA_CONTROL_REGISTER_INTERNAL_GENLOCK |
        VDMA_CONTROL_REGISTER_CIRCULAR_PARK);


    while((vdma_get(handle, 0x30)&1)==0 || (vdma_get(handle, 0x34)&1)==1) {
        printf("Waiting for VDMA to start running...\n");
        sleep(1);
    }
    
    // Extra register index, use first 16 frame pointer registers
    vdma_set(handle, OFFSET_VDMA_S2MM_REG_INDEX, 0);

    // Write physical addresses to control register
    vdma_set(handle, OFFSET_VDMA_S2MM_FRAMEBUFFER1, handle->fb1PhysicalAddress);
    vdma_set(handle, OFFSET_VDMA_MM2S_FRAMEBUFFER1, handle->fb1PhysicalAddress);
    vdma_set(handle, OFFSET_VDMA_S2MM_FRAMEBUFFER2, handle->fb2PhysicalAddress);
    vdma_set(handle, OFFSET_VDMA_MM2S_FRAMEBUFFER2, handle->fb2PhysicalAddress);
    vdma_set(handle, OFFSET_VDMA_S2MM_FRAMEBUFFER3, handle->fb3PhysicalAddress);
    vdma_set(handle, OFFSET_VDMA_MM2S_FRAMEBUFFER3, handle->fb3PhysicalAddress);
    
    // Write Park pointer register
    vdma_set(handle, OFFSET_PARK_PTR_REG, 0);

    // Frame delay and stride (bytes)
    vdma_set(handle, OFFSET_VDMA_S2MM_FRMDLY_STRIDE, handle->width*handle->pixelLength);
    vdma_set(handle, OFFSET_VDMA_MM2S_FRMDLY_STRIDE, handle->width*handle->pixelLength);
    
    // Write horizontal size (bytes)
    vdma_set(handle, OFFSET_VDMA_S2MM_HSIZE, handle->width*handle->pixelLength);
    vdma_set(handle, OFFSET_VDMA_MM2S_HSIZE, handle->width*handle->pixelLength);    

    // Write vertical size (lines), this actually starts the transfer
    vdma_set(handle, OFFSET_VDMA_S2MM_VSIZE, handle->height);
    vdma_set(handle, OFFSET_VDMA_MM2S_VSIZE, handle->height);
}

int vdma_running(vdma_handle *handle) {
    // Check whether VDMA is running, that is ready to start transfers
    return (vdma_get(handle, 0x34)&1)==1;
}

int vdma_idle(vdma_handle *handle) {
    // Check whtether VDMA is transferring
    return (vdma_get(handle, OFFSET_VDMA_S2MM_STATUS_REGISTER) & VDMA_STATUS_REGISTER_FrameCountInterrupt)!=0;
}

int main() {
    int j, i;
    vdma_handle handle;
    
    // Setup VDMA handle and memory-mapped ranges
    vdma_setup(&handle, 0x43000000, 640, 480, 4, 0x0e000000, 0x0f000000, 0x10000000);
    
    // Start triple buffering
    vdma_start_triple_buffering(&handle);
    
    // Run for 10 seconds, just monitor status registers
    for(i=0; i<10; i++) {
        vdma_s2mm_status_dump(&handle);
        vdma_mm2s_status_dump(&handle);
        printf("FB1:\n");
        for (j = 0; j < 256; j++) printf(" %02x", handle.fb1VirtualAddress[j]); printf("\n");
        sleep(1);
    }
    
    // Halt VDMA and unmap memory ranges
    vdma_halt(&handle);
}


