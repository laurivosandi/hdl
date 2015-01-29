import os, png, mmap, BaseHTTPServer

FRAMEBUFFER_OFFSET=0x0e000000
WIDTH = 640
HEIGHT = 480
PIXEL_SIZE = 4

fh = os.open("/dev/mem", os.O_SYNC | os.O_RDONLY) # Disable cache, read-only
mm = mmap.mmap(fh, WIDTH*HEIGHT*PIXEL_SIZE, mmap.MAP_SHARED, mmap.PROT_READ, offset=FRAMEBUFFER_OFFSET)
class MyHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    def do_GET(s):
        writer = png.Writer(WIDTH, HEIGHT, alpha=True)
        s.send_response(200)
        s.send_header("Content-type", "image/png")
        s.end_headers()
        writer.write_array(s.wfile,[ord(j) for j in mm[0:WIDTH*HEIGHT*PIXEL_SIZE]] )

httpd = BaseHTTPServer.HTTPServer(("0.0.0.0", 80), MyHandler)
try:
    httpd.serve_forever()
except KeyboardInterrupt:
    pass
httpd.server_close()

mm.close()
fh.close()

