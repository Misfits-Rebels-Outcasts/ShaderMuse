#  Shaders Gallery - Testing In Progress

Please feel free to share your pipeline design here.

#### Lake Noise
<img src=Lake.gif width="30%" height="30%">  

Pipeline

0. Sunflower Image
1. Color Controls - 0
2. Radial Gradient - none
3. FBM Noise - none
4. Difference Blend Mode - 3,"2"

<img src=LakePipeline.jpg width="30%" height="30%">  

[Pipeline File](Lake.json) - See the section below on how to import this file into the app.

#### Artsy Flower
<img src=ArtsyFlower.gif width="30%" height="30%"> 

Pipeline

0. Sunflower Image
1. Color Controls - 0
2. FBM Noise - none
2. Kaleidoscope - 2 : Count - 15, Angle - 143
4. Particles - 3
5. Difference Blend Mode - 4, "0"

#### Comic Puzzle
<img src=ComicPuzzle.gif width="30%" height="30%">  

Pipeline

0. Sunflower Image
1. Color Controls - 0
2. FBM Noise - none
3. Crystallize - 2 : Radius - 36
4. Comic Effect - 3
5. Sinusoidal Gradient - none
5. Mix - 5, "4"

#### Gradient Flow
<img src=GradientFlow.gif width="30%" height="30%"> 

0. Sunflower Image
1. Color Controls - 0
2. FBM Noise - none
3. Gaussian Gradient - none : Radius - 605
4. Color Dodge Blend Mode - 3,"2"
5. Color Dodge Blend Mode - 4,"0"
6. Color Invert - 5

#### Arty Metal
<img src=ArtyMetal.gif width="30%" height="30%"> 

Pipeline

0. Sunflower Image
1. Color Controls - 0
2. Pointillize - 1 : Radius - 20
3. FBM Noise - none
4. Darken Blend Mode - 3, "2"
5. Difference Blend Mode - 4, "0"

#### Sinusoidal Noise
<img src=SinusoidalNoise.gif width="30%" height="30%"> 

Pipeline

0. Sunflower Image
1. Sinusoidal Gradient - none
2. FBM Noise - none
4. Subtract Blend Mode - 2,"1"

### How to load the pipeline document in this gallery?

The pipeline json file is available in this gallery folder.

1. Download the pipeline file.
2. In the app, tap on the document icon, top left corner, in the Pipeline app.
3. Select Nodef Documents->Others->Import.
4. Select the downloaded file.

