# Source Code License - GPLv2

Shader Muse
Copyright (C) 2023 djembe-waka 

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# Compile

### Prerequisites

* XCode 14
* iOS 16

### Build

* Download the Source Code
* Launch XCode and load Pipeline.xcodeproj 
* Build and run on iPhone Simulator or Device

<img src=ShaderMuseCompile.jpg>

### Notes

For deployment to the App Store, the photo in Shader mode is downscale with the following:

```
let downsampledImage = ImageUtil.downsample(imageAt: filePath, to: UIScreen.main.bounds.size, 
					scale: UIScreen.main.scale / appSettings.shaderDownScale)
```

Change shaderDownScale to a smaller value to create a higher resolution video.

### Creating your own Metal Shader and integrating it with the Pipline.

For creating your own Metal Shader and integrating it with the Pipeline, search for FractalFlowNoiseFX.swift in the source code. This a wrapper of the Metal Shader that integrates it to the Digital Compositing Pipeline.



