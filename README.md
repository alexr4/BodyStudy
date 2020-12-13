# Codevember2020
![gif](https://arivaux.com/prototype/WO-Part1-5-_1.gif)

This repository regroups all the Body Experiments started on Codevember 2020.
Codevember is a coding challenge proposing to create a creative coding experiment each day during the month of November. 
Once again, in 2020, I’ve tried it, but this year was quite different. I’ve streamed each experiment on instagram and on twitch. 
I’ve also followed some rules to keep it simple and iterate more, which were the following:

• Plateform: Unity3D
• Theme: Body interpretation
• Exploring shading, compute shadersand more...
• Try to use colors ;)
• Keep each stream between 3h - 4h

Please, keep in mind this was an experiment done in a few hours. It was not meant to be a tutorial and you might find some errors/bugs.

You can find all the animated results on [instagram](https://www.instagram.com/arivaux/).
You could also rewatch all the streams on [youtube](https://www.youtube.com/user/AlexRivaux/)

## Under the hood
This experiments wa made on **Unity 2019 (LTS)** in legacy mode. VFXGraph effect was not used, so if you lokking for a VFX Graph effect example this not the repo you are looking for.
Maybe check the one from [Keijiro Takashi: SMRVFX](https://github.com/keijiro/Smrvfx).

This experiment relies on various key concepts which are : 

### Skinned Mesh
I used a animated skinned mesh which serves as a reference for the body interpretations.
The mesh is animated using [Mixamo](https://www.mixamo.com/).
_MixamoRigController.cs_ handles all the skinned mesh process such as : 
* Retreiving Rig positions using _MixamoRigg_ tag as an identifier for each rig object
* Baking the skinned mesh using '''SkinnedMeshRenderer.BakeMesh()''' in order to retreive the vrteices and normals
* Geting the TRS (Translate, Rotate & Scale) Matrix from the Skinned Mesh for world position

### Compute Shaders and GPU Instances
All the experiments were made using GPU instancing via the '''Graphics.DrawMeshInstancedIndirect''' method.
Each instance can be animated using a **Compute Shader**.
All the instance use a custome Surface Shader for rendering.
The data from the compute shader are directly boudn to the surface shader to avoid any CPU read back.

Some experiments also use (Vertex Animation Texture)[https://www.sidefx.com/tutorials/unity-shaders-for-vertex-animation-export-tools/] made in Houdini.

## Appendix
* The Neo Man used is a fork fork from Keijiro Takshi [NeoLowMan](https://github.com/keijiro/NeoLowMan) with more subdivisions
* Some PBR Textures come from [CC0Texture](https://cc0textures.com/)
* 3D models are Royalty Free Models to used from [Turbosquid](https://www.turbosquid.com/) and [CGTraders](https://www.cgtrader.com/).
* Rocks Models (1, 2, 3) on Body interpretation 7 was made by [Kless Gyzen](https://sketchfab.com/klessgyzen)
* For streaming purpose and export, this repo use the following elements
* * Forked version of [FFMPEGOut](https://github.com/keijiro/FFmpegOut) from Keijiro Takashi
* * [KlakNDI](https://github.com/keijiro/KlakNDI) from Keijiro Takashi in order to broadcast result from unity to OBS studio on another computer.

## Licences
This work is licensed under a [Creative Common Attribution NonCommercial ShareAlike](https://creativecommons.org/licenses/by-nc-sa/4.0/)
[![License: CC BY-NC-SA 4.0](https://licensebuttons.net/l/by-nc-sa/4.0/80x15.png)](http://creativecommons.org/licenses/by-nc-sa/4.0/)