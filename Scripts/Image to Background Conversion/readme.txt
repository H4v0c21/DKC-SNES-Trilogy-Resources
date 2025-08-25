DISCLAIMER:
This process requires that you know how to safely write binary data to your ROM manually. If any of the words listed below scare you then you're probably not ready to do this:

Data compression
Addresses/Pointers
Hexadecimal/Raw binary data
VRAM payloads/Graphics upload routines



If you still want to attempt anyways then MAKE BACKUPS FIRST! This can permanently delete data in your ROM if done incorrectly.

CONVERSION/GENERAL USE:

Use this website with your image to generate a suitable input image for the script: https://rilden.github.io/tiledpalettequant/
Alternatively you can open the "Tiled Palette Quantization.html" located in the "Quantization Webpage" folder in a web browser.

Make sure to use these settings:
Palettes: 8
Colors per palette: 16
Color index zero behavior: shared color (You can choose whatever background color you want)

Click "Quantize" then download the image.
Open the image in an image editor your choice like Photoshop/GIMP and convert it to PNG format (Make sure the color format remains indexed).

Drag your newly converted/quantized PNG image into the "CONVERT (DRAG AND DROP HERE).bat" file.
Make sure you're dropping the OUTPUT file from "Tiled Palette Quantization" webpage that you just converted to PNG.
DO NOT use the INPUT file you initially used with the "Tiled Palette Quantization" webpage or the BMP file that it outputs for this step.



ROM INSERTION:

More information on how to insert the output data into ROM will be added at a later date.

Palette data can be inserted using Super Palette Imager:
https://github.com/H4v0c21/Super_Palette_Imager/releases

Tiledata and Tilemaps can be inserted with a hex editor or asar.
Be sure to set your compression flags, pointers, and sizes correctly in the ROM.
Also make sure that you don't insert data that is too large for the previous data's allocated space as this may corrupt the data stored directly after.

Currently the compression format used is DKC 2/3 Big data.

If the size of "compressed_tiledata.bin" is larger than "tiledata.bin" it is advised that you don't use the compressed version in ROM as it is a waste of space.
Instead use the uncompressed version named "tiledata.bin" and set your compression flags for the data in ROM accordingly.



SOURCE/LICENSING:
This project/integration (excluding the dependencies required) was created by H4v0c21.
https://github.com/H4v0c21

DEPENDENCIES:
tiledpalettequant: https://github.com/rilden/tiledpalettequant
superfamiconv: https://github.com/Optiroc/SuperFamiconv
dkcomp: https://github.com/Kingizor/dkcomp

All included programs use the following license:

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.