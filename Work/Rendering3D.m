%%%%%%%%%%%%%%%%%%%%%%%%%%%Global Variables%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Light
lightPosition = [0 0 0];
lightColor = [0 0 0];
ambientLightColor = [0 0 0];
emissiveColor = [.5 .5 .5]; % gray
diffueseColor = [];
specularColor = [];

%Camera
cameraPosition = [0 0 0];
cameraPoint = [0 0 0];

%Object
objectPosition = [5 0 0];
objectOrientation = [90 90 90];    %degrees

%Other
fieldOfView = 90;
nearFustrum = 1;
farFustrum = 100;
aspectRatio = 1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sceneData = importdata('shuttle_breneman_whitfield.raw');   %Get shuttle data

%Rotation
rotX = [1 0 0 0;
        0 cosd(objectOrientation(1)) sind(objectOrientation(1)) 0; 
        0 -sind(objectOrientation(1)) cosd(objectOrientation(1)) 0;
        0 0 0 1];
    
rotY = [cosd(objectOrientation(2)) -sind(objectOrientation(2)) 0 0; 
        0 1 0 0 
        sind(objectOrientation(2)) cosd(objectOrientation(2)) 0 0;
        0 0 0 1];

rotZ = [cosd(objectOrientation(3)) sind(objectOrientation(3)) 0 0; 
        -sind(objectOrientation(3)) cosd(objectOrientation(3)) 0 0;
        0 0 1 0;
        0 0 0 1];

rotationMatrix = rotX*rotY*rotZ;
    
%World Transformation
worldTrans = [1 0 0 0;
             0 1 0 0;
             0 0 1 0;
             objectPosition 1];
         
%View Transformation

%Projection Transformation

%Perspective Effect

%Lighting

%Apple to all points
for i = 1:length(sceneData)
    %get the correct triangle
    points = [sceneData(i, 1:3) 1; sceneData(i, 4:6) 1; sceneData(i, 7:9) 1];
    points = points * worldTrans;
    patch(points(:,1), points(:,2), points(:,3), 'EdgeColor', 'none');
 
end