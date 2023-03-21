#  Digital Compositing Metal Shaders and CIFilter

Shader Muse explores the fun from mixing/chaining to Digital Compositing of Photo Images, Graphic Shaders (Apple Metal Shaders), and Image Filters (Core Image CIFilter). 

For example, we explore the fun of mixing this Image 

<img src=documentation/Malacca.JPG width="50%" height="50%">

with this Shader (Fractal Flow Noise)

<img src=documentation/FractalFlowNoise.JPG width="50%" height="50%">

to get this <a href="documentation/FireShaderAndSmokeEffect.mp4">Photo Fire Effects Video</a>.

<img src=documentation/FireFlameShaderPhotoEffect.JPG width="50%" height="50%">

## What is a Shader?

Image Filters is common and easily understood. Many modern software applications or apps provide image filtering capabilities. But then what is a Shader? From Wikipedia, we know that "a shader is a computer program that calculates the appropriate levels of light, darkness, and color during the rendering of a 3D scene—a process known as shading.". From the Book of Shaders, "Shaders are ... a set of instructions, but the instructions are executed all at once for every single pixel on the screen." 

In other words, a Shader is a set of computer instructions (computer program) that affects the light, darkness, and color etc. of an image and it runs fast. Beyond the above, it can also perform things like animations or procedural texture image generation.

## Fire Flame Shader Photo Effect 

With the above being said, let's get started to mix our Filters and Shader to get our photo effect. We are going to use Swift, Core Image CIFilter, and Apple Metal Shader to achieve the above. 

The original photo is shown in first inage above. 

It is possible to develop a Metal Shader that generates the entire Fire Shader Photo Effect above. But instead, we are going to use Digital Compositing concepts to create a Pipeline (Node Graph) of CIFilter and a more minimal Metal Shader to achieve this. With a Digital Compositing Pipeline, we can easily swap out filters in the compiled app, for example, from a Gaussian Blur to a Motion Blur, to see how it affects our photo effect.

## Fractal Flow Noise Shader 

The Metal Shader we have developed for use in the Fire Effect is a Fractal Flow Noise Shader. This Shader is a fractal sum of a given base image. What this means is that it takes a basic image file, makes many copies of it, some zoomed, some rotated, and blends them together. The blending is not uniform, however. The images that are zoomed smaller (having a higher frequency) will be blended with a lighter weight.  

<img src=documentation/FractalFlowNoise.JPG width="50%" height="50%">

We also animate each copy of the basic image so that they move independently from each other. Furthermore, the animation of the pixels in each copy is dependent on the location of the pixel. Some pixels will move / rotate / scale faster than other pixels. This complex combination gives rise to animation effects that are able to simulate some natural phenomenon such as flame and gas.

#### Fractal Sum

This main work is performed in the 'turbulance_p' function. If you look at it closely, you will notice a loop that makes 24 copies of the image

for (float i= 1.0;i <24.0;i++ )

For each iteration, the image is zoomed out by 1.4, while the weight is reduced by 1.5. The zooming is achieved using the pixel position represented by the variable p described in the previous section

amplitude *= 1.5; //weight
pos *= 1.4; //scale

So the final sum is something like a series as below

val = amplitude * sample(pos) + amplitude * 1/1.5 * sample(pos*1.4)  + amplitude * 1/1.5 * 1/1.5 * sample(pos*1.4*1.4)  + ....

Note : The val (float3) is not just a single value. It is a 3D vector that represents the sampled value of each of the components Red, Green , Blue of the final color that is returned 

Note : To zoom out the image, we simply multiply the sampling coordinates by 1.4 for each iteration.
So if we originally sample at the uv coordinates 0.0 to 1.0, the next iteration will be sampled at 0.0 to 1.4

Please check out the complete description of the source code of the Fractal Flow Noise Shader below.


#### Animation
To make the result even more interesting, we try to animate each copy of the basic image according to the time elapsed. The animation is a simple movement / shift of the image copy. The higher the frequency (image zoomed smaller), the more it is shifted.

The amount of shift is tracked by the variable newpos. For each iteration, the shift increases like a geometric series

newpos+= t*0.23;

In series form, the new position will take the form
newpos = pos + t * 0.23 + t * t * 0.23 * 0.23 + t * t * t * 0.23 * 0.23 * 0.23 + .....

We do not sample the zoomed copy of the basic image using just the 'newpos' variable. Here, we introduce an additional control parameter known as 'strength'. This 'strength' variable is just a weight to control the amount of shift / movement. For the current implementation, this weight is a constant factor at 0.5. There is no restriction or whatever why it cannot vary according to each iteration.


adv = (newpos - pos)*strength; 
pos = pos + adv;

//comment : take the average between the desired new position and current position and use the value (pos) to sample the image 

Due to the computation of the 'newpos' variable as a linear direction, the animation will generally take the form of a main direction (with varying speeds for each copy). Now we want to make different parts of the image move differently, so we create distribution functions that vary according to the position 'p' of the current pixel. These distribution functions (named pdf and pdf2 for the x and y axes), form a layer that allows each pixel of each image copy to move slightly differently from its neighbors.

Example: for pdf1 and pdf2 functions
float val = abs(atan(p.y*0.9543))*(cos(p.x*0.9532)+sinh(p.y*0.9816));
float val = length(p)*(cos(p.y/p.x*0.9532)+sinh(p.y*0.9816));

The original implementation of these probability distribution functions are based approximately on polar coordinates with the length and arctangent functions.  The actual implementation makes modifications to them largely by trial and error. The main intent is for these functions to be periodic , so you will notice the presence of sinusoidal and hyperbolic functions. To generate an interesting animation, these functions and their parameters are arbitrarily selected, and the reader may want to experiment by plugging different types of functions and parameters values to 'engineer' some other variations.

## Gaussian Difference Mask

To achieve the effect of the simulated fire (Fractal Flow Noise) occuring naturally in the original photo, we need to blend the Fractal Flow Noise Shader using a Gaussian Difference Mask. 
 
A Gaussian Difference Mask is a "difference of Gaussians (DoG) is a feature enhancement algorithm that involves the subtraction of one Gaussian blurred version of an original image from another, less blurred version of the original. (Wikipedia https://en.wikipedia.org/wiki/Difference_of_Gaussians)

This mask "can be utilized to increase the visibility of edges and other detail present in a digital image. A wide variety of alternative edge sharpening filters operate by enhancing high frequency detail, but because random noise also has a high spatial frequency, many of these sharpening filters tend to enhance noise, which can be an undesirable artifact. The difference of Gaussians algorithm removes high frequency detail that often includes random noise, rendering this approach one of the most suitable for processing images with a high degree of noise." (Wikipedia https://en.wikipedia.org/wiki/Difference_of_Gaussians)

### Node Graph

We can also use a Digital Compositing Node Graph with Core Image CIFilter names to illustrate what we are doing above:

     Original Image    
     |           
     V           
     CIPhotoEffectNoir    
     |           
     V           
     CIColorInvert    
     |               |     
     V               V     
     CIGaussianBlur  CIGaussianBlur
     |               |     
     V               V     
     CIColorDodgeBlend  

This gives us a mask for our Fire Effect as shown below:

<img src=documentation/GaussianDifferenceMask.JPG width="50%" height="50%">

We can use different Radius values in the two Gaussian Blur to vary the output of our Color Dodge Blend. Below are some sample values.

Gaussian Blur Radius - 14.88 (or 5.18)

Gaussian Blur Radius - 4.63

## Fire Shader Effect 

     Original Image    
     |                |           
     |                V           
     |                CIPhotoEffectNoir    
     |                |           
     |                V           
     |                CIColorInvert    
     |                |               |     
     |                V               V     
     |                CIGaussianBlur  CIGaussianBlur
     |                |               |     
     |                V               V     
     |                CIColorDodgeBlend    CIFractalFlowNoise
     |                |                    |     
     V                V                    V     
     CIBlendWithMask (input - Original Image, background - CIFractalFlowNoise, mask - CIColorDodgeBlend) 
               
                
### What is Digital Compositing?

Digital Compositing (node-based) is the process of combining multiple seemingly simple nodes to render and achieve a desired result. The paradigm of a node-based tool involves linking basic media objects onto a procedural map or node graph and then intuitively laying out each of the steps in a sequential progression of inputs and outputs. Any parameters from an earlier step can be modified to change the final outcome, with the results instantly being visible to you, and each of the nodes, being procedural, can be easily reused, saving time and effort.

### Why Digital Compositing?

In our chaining and mixing of Shaders and Filters above, ...

### What is Digital Compositing Pipeline?

We can also express the Node Graph succintly in English using a simple list below which can easily be displayed on our mobile device. 

0. Original Image
1. Photo Effect Noir
2. Color Invert
3. Gaussian Blur (2)
4. Gaussian Blur (2)
5. Color Dodge Blend (3,4)

We apply a Photo Effect Noir filter on the original image and then chain the output to a Color Invert. In Step 3-4, we create Gaussian Blur based on the output of the Color Invert. The (2) refers to the input image used by both of the Gaussian Blur. Finally we apply a Color Dodge Blend on the two Gaussian Blur to achieve the Gaussian Difference Mask. 

See [Open Source Digital Compositing Pipeline](https://Misfits-Rebels-Outcasts/Nodef/NodePipeline.md) for more information.

## Fire Shader Effect with a Digital Compositing Pipeline of Metal Shaders and CIfilter

Finally, we perform a Blend With Mask with the original image and a Fractal Flow Noise using the mask above. This is shown below:

0. Original Image
1. Photo Effect Noir
2. Color Invert
3. Gaussian Blur (2)
4. Gaussian Blur (2)
5. Color Dodge Blend (3,4)
6. Fractal Flow Noise (0)
7. Blend With Mask (input - 0, background - 6, mask - 5)

In Core Image CIFilter programming, we chain the CIFilter and Metal Shader as shown below:

0. Original Image
1. CIPhotoEffectNoir - inputImage 0
2. CIColorInvert - inputImage 0 
3. CIGaussianBlur - inputImage 2
4. CIGaussianBlur - inputImage 2
5. CIColorDodgeBlend - inputImage 3 , backgroundImage 4
6. CIFractalFlow Noise - inputImage 0
7. CIBlendWithMask - inputImage 0 , backgroundImage 6, maskImage 5

The photo effect now looks like the following:


We can also test out all the concepts above in the compiled app: Nodef Digital Compositing Pipeline. 

https://apps.apple.com/us/app/nodef-photo-filters-effects/id1640788489

## Why Digital Compositing?

Why go through all the trouble? Why not just put everything in code?

For example, we can further add Smoke to Fire using a Fractal Brownian Motion Noise Shader. The source code of this shader is also available in the repo. 

0. Original Image
1. Photo Effect Noir
2. Color Invert
3. Gaussian Blur (2)
4. Gaussian Blur (2)
5. Color Dodge Blend (3,4)
6. Fractal Flow Noise (0)
7. Blend With Mask (input - 0, background - 6, mask - 5)
8. FBM Noise
9. Mix (8,0)

<img src=documentation/FireShaderEffectsDigitalCompositingPipeline.jpeg width="40%" height="40%">

[Video]

## Project
Source Code (Coming Soon)

### Open-Source Project (GPL)

An open-source node-based photo filters and effects compositor is created to test the ideas above.
[Node-based Compositing on Mobile](documentation/NodeBasedCompositingOnMobile.md)

### Platform

* iOS
* iPadOS
* Mac

Programming Language
* Swift


## Epilogue

After the plague, "quando nella egregia città di Fiorenza, oltre a ogn'altra italica bellissima, pervenne la mortifera pestilenza" (Decameron), while traveling, in the beautiful far east town of Malacca, a fire occured, and both the town and skyline in front of our window was ablazed with a red orange color. 

Memento Mori, Memento Vivere.


# Metal Shaders  

FBM Noise - Morgan Mcguire @morgan3d

+ [Fractal Flow Noise Shader](documentation/FractalFlowNoiseShader.md)

Particles

and over 150 CIFilter for Digital Compositing

