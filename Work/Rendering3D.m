%%%%%%%%%%%%%%%%%%%%%%%%%%%GLOBAL VARIABLES%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Light
lightPosition = [0 0 0];
lightColor = [0 0 0];
ambientLightColor = [0.5 0.5 0.5];
ambientM = [0 0 0];
emissiveM = [.5 .5 .5];
diffuseM = [.05 .05 .05];
specularM = [.3 .3 .3];

%Camera
cameraPosition = [100 100 -100];
cameraPoint = [0 0 0];

%Object
objectPosition = [5 0 0];
objectOrientation = [0 0 0];    %degrees

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

%Lighting
%     %ambient
%     lighting = ambient .* ambientMat;
%     
%     %diffuse
%     maxVal = max(dot(points(1, 1:3) - lightPos, normal), 0);
%     cDiff = maxVal * lightColor .* diffuseMat;
%     lighting = lighting + cDiff;
%     
%     %specular
%     v1 = mean(points(:, 1:3)) - lightPos;
%     v2 = mean(points(:, 1:3)) - cameraPos;
%     hNorm = (v1 + v2) ./ abs(v1 + v2);
%     hNorm = hNorm / norm(hNorm);
%     cSpec = max(dot(normal, hNorm), 0) ^ S * lightColor .* specularMat;
%     lighting = lighting + cSpec;
%     
%     %emissive
%     lighting = lighting + emissiveMat;

%Apple to all points
for i = 1:length(sceneData)
    %Get a triangle
    triangle = [sceneData(i, 1:3) 1; sceneData(i, 4:6) 1; sceneData(i, 7:9) 1];
    
    %World Translation
    triangle = triangle * worldTranslationMatrix;   %Translate into world space
    triangle = triangle * rotationMatrix; %Rotate in world space
    
    %Lighting
    %ambient lighting
    lighting = ambientLightColor*ambientM;
    
    %diffuse lighting
    lighting = lighting + lightColor*diffuseM;

    %specular lighting
    lighting = lighting + lightColor*specularM;

    %emissinve lighting
    lighting = lighting + emissiveM;
    
    
    %View and Projection
    triangle = triangle * viewProjMatrix; %Apply view and projection

    %Dividing by W
    for j=1:3
        triangle(j,1:3) = triangle(j,1:3)./triangle(j,4);
    end
    
    patch(triangle(:,1), triangle(:,2), [rand(1) rand(1) rand(1)], 'EdgeColor', 'none');
 
end