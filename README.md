#  Digital Compositing Metal Shaders and CIFilter

Shader Muse explores the fun from Mixing, Chaining, and Digital Compositing Photo Images, Graphic Shaders (Apple Metal Shaders), and Image Filters (Core Image CIFilter). 

For example, we explore the fun of mixing this Image 

<img src=documentation/Malacca.JPG width="50%" height="50%">

with this Shader (Fractal Flow Noise)

<img src=documentation/FractalFlowNoise.JPG width="50%" height="50%">

to get this <a href="documentation/FireShaderAndSmokeEffect.mp4">Photo Fire Effects Video</a> (mp4 video).

<img src=documentation/FireFlameShaderPhotoEffect.JPG width="50%" height="50%">

Beyond the fun, we explore the advantages of surfacing the properties of shaders and filters through a Digital Compositing Pipeline, enabling an end user such as a creative graphics designer to make changes to the node graph without programming.

## Fire Flame Shader Photo Effect 

To create the Fire Photo Effect, we first develop a "fire like" Shader and use a mask to create the effect of edges on the image catching fire. A Difference of Gaussian on the grayscale of the original image is first computed and then used to produce a sketch effect mask.

We need to chain several filters to create the mask and a blend with mask filter to put everything together. Our project uses Swift, Core Image CIFilter, and Apple Metal Shader to achieve all this.

#### Just in case: What is a Shader?

Image Filters is common and easily understood. Many modern software applications or apps provide image filtering capabilities. But then what is a Shader? From Wikipedia, we know that "a shader is a computer program that calculates the appropriate levels of light, darkness, and color during the rendering of a ... process known as shading.". 

In other words, a Shader is a set of computer instructions (computer program) that affects the light, darkness, and color etc. of an image and it runs fast. Beyond the above, it can also perform things like animations or procedural texture image generation.

### Fractal Flow Noise Shader 

* FractalFlowNoiseFilter.swift
* fractalFlowNoise.metal

The Metal Shader we have developed for use in the Fire Effect is a Fractal Flow Noise Shader. This Shader is a fractal sum of a given base image. What this means is that it takes a basic image file, makes many copies of it, some zoomed, some rotated, and blends them together. The blending is not uniform, however. The images that are zoomed smaller (having a higher frequency) will be blended with a lighter weight.  

<img src=documentation/FractalFlowNoise.JPG width="50%" height="50%">

We also animate each copy of the basic image so that they move independently from each other. Furthermore, the animation of the pixels in each copy is dependent on the location of the pixel. Some pixels will move / rotate / scale faster than other pixels. This complex combination gives rise to animation effects that can simulate some natural phenomenon such as flame and gas.

#### Fractal Sum

This main work is performed in the 'turbulance_p' function. If you look at it closely, you will notice a loop that makes 24 copies of the image

for (float i= 1.0;i <24.0;i++ )

For each iteration, the image is zoomed out by 1.4, while the weight is reduced by 1.5. The zooming is achieved using the pixel position represented by the variable p described in the previous section

amplitude *= 1.5; //weight
pos *= 1.4; //scale

So, the final sum is something like a series as below

val = amplitude * sample(pos) + amplitude * 1/1.5 * sample(pos*1.4)  + amplitude * 1/1.5 * 1/1.5 * sample(pos*1.4*1.4)  + ....

Note : The val (float3) is not just a single value. It is a 3D vector that represents the sampled value of each of the components Red, Green , Blue of the final color that is returned 

Note : To zoom out the image, we simply multiply the sampling coordinates by 1.4 for each iteration.
So, if we originally sample at the uv coordinates 0.0 to 1.0, the next iteration will be sampled at 0.0 to 1.4

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

The original implementation of these probability distribution functions is based approximately on polar coordinates with the length and arctangent functions.  The actual implementation makes modifications to them largely by trial and error. The main intent is for these functions to be periodic , so you will notice the presence of sinusoidal and hyperbolic functions. To generate an interesting animation, these functions and their parameters are arbitrarily selected, and the reader may want to experiment by plugging different types of functions and parameters values to 'engineer' some other variations.

### Difference of Gaussian Sketch Mask

With the "fire" (Fractal Flow Noise Shader), we now need to make it occur naturally in the original image. In our implementation, we use a Difference of Gaussians for creating the mask. We compute a sketch of the original image and use it as a mask to blend it with the "fire" Shader to make the edges of some parts of the image look like it is catching fire. We can use a node graph of CIFilter to illustrate how we get the mask.   

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

We use different Radius values in the two Gaussian Blur to vary the output of our Color Dodge Blend. Below are some sample values.

* Gaussian Blur 1 Radius - 14.88 (or 5.18)
* Gaussian Blur 2 Radius - 4.63

## Fire Shader Effect 

     Original Image                         
     |                 
     |                CIFractalFlowNoise   CIColorDodgeBlend 
     |                |                    |     
     V                V                    V     
     CIBlendWithMask 
     
     
The CIBlendWithMask uses the Original Image as the input image, CIFractalFlowNoise as the background image, and the output of CIColorDodgeBlend (DoG) as the mask.

<img src=documentation/FireFlameShaderPhotoEffect.JPG width="50%" height="50%">
          
## Fire Shader Effect - Full Node Graph

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

## Why use Digital Compositing on Shaders?

It is possible to develop a Metal Shader to generate the entire Fire Shader Photo Effect above. But instead, we have chosen to apply Digital Compositing concepts and created a node graph of CIFilter with a considerably basic Metal Shader to achieve the same thing. 

**The advantage of doing this is many of the programming steps is now surfaced and is controllable by a user. For example, a graphics designer using an app that uses a Digital Compositing node graph can easily swap in a better "fire" or "mask". Or add additional steps to control the exposure or color correct their video.**

### Just in case: what is Digital Compositing?

Digital Compositing (node-based) is the process of combining multiple seemingly simple nodes to render and achieve a desired result. The paradigm of a node-based tool involves linking basic media objects onto a procedural map or node graph and then intuitively laying out each of the steps in a sequential progression of inputs and outputs. Any parameters from an earlier step can be modified to change the outcome, with the results instantly being visible to you, and each of the nodes, being procedural, can be easily reused, saving time and effort.

## Beyond a Node Graph: Digital Compositing Pipeline

We can also express the node graph above succinctly in English as a list of steps.

0. Original Image (none)
1. Photo Effect Noir (0)
2. Color Invert (1)
3. Gaussian Blur (2)
4. Gaussian Blur (2)
5. Color Dodge Blend (3,4)
6. Fractal Flow Noise (none)
7. Blend With Mask (input - 0, background - 6, mask - 5)

The (0) in step 1 refers to the input image used by the Photo Effect Noir filter. Steps 3, 4, and 5 compute the Difference of Gaussians of the grayscale image to produce a sketch effect that is further used as a mask to create the effects of edges catching fire. 

## Why use a Digital Compositing Pipeline?

Displaying a node graph as a list of steps, a [Digital Compositing Pipeline](https://github.com/Misfits-Rebels-Outcasts/Nodef/blob/main/documentation/NodePipeline.md) (invented by Nodef), is very useful in circumstances when there is limited screen space. For example, in times when we need to view or change a node graph on a mobile device. 

Shader Muse forked [Nodef](https://github.com/Misfits-Rebels-Outcasts/Nodef) project to enable Digital Compositing of Shaders and Filters in iOS (iPhone, iPad, and Mac).

<img src=documentation/FireShaderEffectsDigitalCompositingPipeline.jpeg width="40%" height="40%">

Check out the compiled app of Shader Muse: *[Pipeline](https://apps.apple.com/us/app/nodef-photo-filters-effects/id1640788489)*.

## Adding Smoke to the Fire Effect

1. Download and run the Shader Muse [Pipeline](https://apps.apple.com/us/app/nodef-photo-filters-effects/id1640788489) app - 
2. In the Presets of the app, tap on the FIRE preset to apply the Fire Effect.

<img src=documentation/FirePreset.jpeg width="40%" height="40%">

3. Tap on the "f" button to view the Digital Compositing Pipeline of our Fire Effect.
4. We can further enhance this effect by adding smoke: "FBM Noise" Shader.
4. Next add a "Mix" Composite Filter to mix our Fire Effects with the "FBM Noise".
5. Tap on the "Mix" node and change the Background to "7".

<img src=documentation/FireShaderEffectsDigitalCompositingPipeline.jpeg width="40%" height="40%">

You can also adjust the intensity of the Fire Effect by tapping on the Gaussian Blur nodes and changing the Radius.

# List of Metal Shaders in Shader Muse 

* FBM Noise - based on 2D Noise by Morgan Mcguire @morgan3d
* [Fractal Flow Noise Shader](documentation/FractalFlowNoiseShader.md)
* Particles

and over 150 CIFilter for Digital Compositing. Please star our project, we will add more Shaders with your encouragement.

# Open-Source Project (GPLv2)

* Source Code (Coming Soon) - in the code folder

## Platform

* iOS
* iPadOS
* Mac

## Programming Language

* Swift
* Metal Shading Language

# Epilogue

After the plague, "quando nella egregia città di Fiorenza, oltre a ogn'altra italica bellissima, pervenne la mortifera pestilenza" (Decameron), while traveling, in the beautiful far east town of Malacca, a fire occured, and both the town and skyline in front of our window was ablazed with a red orange color. 

Memento Mori, Memento Vivere.




