%Left Hand System, -z camera

%%%%%%%%%%%%%%%%%%%%%%%%%%%GLOBAL VARIABLES%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Light
lightPosition = [10 -5 10];
lightColor = [0.52 0.62 0.52];
ambientLightColor = [0.2 0.2 0.2];
ambientM = [0.21 0.31 0.31];
emissiveM = [0.21 0.30 0.43];
diffuseM = [0.52 0.62 0.52];
specularM = [0.54 0.35 0.46];
S = 4;

%Camera
cameraPosition = [100 100 -100];
cameraPoint = [0 0 0];

%Object
objectPosition = [5 0 0];
objectOrientation = [180 0 0];    %degrees

%Other
fieldOfView = 80;
fustrum = [5 50];    %[near far]
aspectRatio = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%GET DATA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sceneData = importdata('shuttle_breneman_whitfield.raw');   %Get shuttle data
   
%%%%%%%%%%%%%%%%%%%%%%%%%WORLD TRANSFORMATION%%%%%%%%%%%%%%%%%%%%%%%%
%World Translation
worldTranslationMatrix = [1 0 0 0;
             0 1 0 0;
             0 0 1 0;
             objectPosition 1];
         
%World Rotation
rotX = [1 0 0 0;
        0 cosd(objectOrientation(1)) sind(objectOrientation(1)) 0; 
        0 -sind(objectOrientation(1)) cosd(objectOrientation(1)) 0;
        0 0 0 1];
    
rotY = [cosd(objectOrientation(2)) -sind(objectOrientation(2)) 0 0; 
        0 1 0 0 
        sind(objectOrientation(2)) 0 cosd(objectOrientation(2)) 0;
        0 0 0 1];

rotZ = [cosd(objectOrientation(3)) sind(objectOrientation(3)) 0 0; 
        -sind(objectOrientation(3)) cosd(objectOrientation(3)) 0 0;
        0 0 1 0;
        0 0 0 1];

rotationMatrix = rotX*rotY*rotZ;             %rotation matrix
         
%%%%%%%%%%%%%%%%%%VIEW TRANSFORMATION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
upVector = [0 1 0];     % y up, camera -z
camView = -cameraPosition + cameraPoint;
camView = camView./norm(camView);

forward = camView; 

right = cross(upVector, forward);
right = right./norm(right);

up = cross(forward, right);
up = up./norm(up);
 
viewMatrix = [right(1) up(1)  forward(1) 0;
              right(2) up(2)  forward(2) 0;
              right(3) up(3)  forward(3) 0;
            -(dot(right,cameraPosition)) -(dot(up,cameraPosition)) -(dot(forward,cameraPosition)) 1];

%%%%%%%%%%%%%%%%%%%PROJECTION TRANSFROMATION%%%%%%%%%%%%%%%%%%%%%%%%%%%%
projectionMatrix = [1/aspectRatio * cotd(fieldOfView/2) 0 0 0;
                    0 cotd(fieldOfView/2) 0 0;
                    0 0 fustrum(2) / (fustrum(2) - fustrum(1)) 1;
                    0 0 -(fustrum(2) * fustrum(1) / (fustrum(2) - fustrum(1))) 0]

viewProjMatrix = viewMatrix;       %Combine the view and projection matrix

%Perspective Effect

%Apple to all points
for i = 1:length(sceneData)
    %Get a triangle
    triangle = [sceneData(i, 1:3) 1; sceneData(i, 4:6) 1; sceneData(i, 7:9) 1];
    
    %%%%%%%%%%%%%%%%%%%WORLD TRANSLATION%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    triangle = triangle * worldTranslationMatrix;   %Translate into world space
    triangle = triangle * rotationMatrix; %Rotate in world space
    
    %%%%%%%%%%%%%%%%%%%VECTOR CALCULATION%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Get the normal
    v1 = triangle(2, 1:3) - triangle(1, 1:3);
    v2 = triangle(3, 1:3) - triangle(1, 1:3);
    normalVector = cross(v1, v2);
    normalVector = normalVector / norm(normalVector);
    
    %Get the light angle
    center = [sum(triangle(1:3,1)) sum(triangle(1:3,2)) sum(triangle(1:3,3))]./3;
    lightVector = lightPosition - center;
    lightVector = lightVector/norm(lightVector);
    
    %Get the eye angle
    eyeVector = cameraPosition - center;
    eyeVector = eyeVector/norm(eyeVector);

    %%%%%%%%%%%%%%%%%%%Lighting%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %ambient lighting
    ambientLighting = ambientLightColor.*ambientM;
    
    %diffuse lighting
    diffuseLighting = max(dot(lightVector, normalVector),0)*(lightColor.*diffuseM)

    %specular lighting
    hVector = (eyeVector + lightVector) ./ abs(eyeVector + lightVector);
    hVector = hVector / norm(hVector);
    specularLighting = max(dot(normalVector, hVector), 0)^S * (lightColor .* specularM);

    %emissinve lighting
    emissiveLighting = emissiveM;
    
    %total lighting
    lighting = ambientLighting + diffuseLighting + specularLighting + emissiveLighting;
    
   %%%%%%%%%%%%%%%%%%%VIEW AND PROJECTION TRANFORMATION%%%%%%%%%%%%%%%
    triangle = triangle * viewProjMatrix; %Apply view and projection

    %%%%%%%%%%%%%%%%%%%%DIVIDE BY W%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for j=1:3
        triangle(j,1:3) = triangle(j,1:3)./triangle(j,4);
    end
    
    %%%%%%%%%%%%%%%%%%%PRINT IMAGE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    patch(triangle(:,1), triangle(:,2), lighting, 'EdgeColor', 'none');
 
end