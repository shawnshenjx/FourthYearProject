# Transformation
This folder contains the matlab version for the transformation of the data
one question remains: even quaternion is invariant of the coordinates, but the quaternion derived rotation matrix may still depends on the convention

## Combine
It transfroms both the OptiTrack data and HoloLens data to the HMD frame, if you run the code, you will see the offset

## Opti and Holoframe
They transform the OptiTrack data and Hololens data to the HMD frame seprately

## Functions
The function with a L ending means it is there for the left hand coordinate systems which is HoloLens datat in our case 

## Transformationandrecognition
This file is the combination that does the transformation and the recognition 
