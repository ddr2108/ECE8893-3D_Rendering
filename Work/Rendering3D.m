%Left Hand System, -z camera

%%%%%%%%%%%%%%%%%%%%%%%%%%%GLOBAL VARIABLES%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Light
lightPosition = [0 0 10];
lightColor = [0.8 0.8 0.8];

%Light Effects
ambientLightColor = [0.1 0.1 0.1];
ambientM = [0.21 0.31 0.31];
emissiveM = [0.21 0.30 0.43];
diffuseM = [0.52 0.62 0.52];
specularM = [0.54 0.35 0.46];
S = 10;

%Camera
cameraPosition = [20 20 20];
cameraPoint = [0 0 0];

%Object
objectPosition = [5 5 5];
objectOrientation = [180 0 0];    %degrees

%Other
fieldOfView = 150;
fustrum = [25 50];    %[near far]
aspectRatio = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%GET DATA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sceneData = importdata('shuttle_breneman_whitfield.raw');   %Get shuttle data

max(sceneData)
   
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
right = right./norm(right)

up = cross(forward, right);
up = up./norm(up);
 
viewMatrix = [right(1) up(1)  forward(1) 0;
              right(2) up(2)  forward(2) 0;
              right(3) up(3)  forward(3) 0;
            -(dot(right,cameraPosition)) -(dot(up,cameraPosition)) -(dot(forward,cameraPosition)) 1]

%%%%%%%%%%%%%%%%%%%PROJECTION TRANSFROMATION%%%%%%%%%%%%%%%%%%%%%%%%%%%%
projectionMatrix = [1/aspectRatio * cotd(fieldOfView/2) 0 0 0;
                    0 cotd(fieldOfView/2) 0 0;
                    0 0 fustrum(2) / (fustrum(2) - fustrum(1)) 1;
                    0 0 -(fustrum(2) * fustrum(1) / (fustrum(2) - fustrum(1))) 0]

viewProjMatrix = viewMatrix%*projectionMatrix      %Combine the view and projection matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%FIGURE SETUP%%%%%%%%%%%%%%%%%%%
figure;
%axis([-1 1 -1 1])
axis square

%%%%%%%%%%%%%%%%%%%%APPLY TO ALL POINTS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
modifiedSceneData = [];
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
    diffuseLighting = max(dot(lightVector, normalVector),0)*(lightColor.*diffuseM);

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
    
    %%%%%%%%%%%%%%%%%%%%%DATA STRUCTURE TO HOLD TRIANGLES%%%%%%%%%%%%%%%
    avgZ = (triangle(1,3) + triangle(2,3) + triangle(3,3))/3;
    triangleDataPoint = [avgZ triangle(1,:) triangle(2,:) triangle(3,:) lighting];
    modifiedSceneData = [modifiedSceneData; triangleDataPoint];
end

%%%%%%%%%%%%%%%%%%%%%%%%%Z SORTING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
modifiedSceneData = sortrows(modifiedSceneData, -1);

%%%%%%%%%%%%%%%%%%%%%%CLIPPING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
finalSceneData = [];
for i=1:length(modifiedSceneData)
       modifiedZ = modifiedSceneData(i, 6:8);
    
      %Check if z is between low and high
      %if (fustrum(1)<modifiedZ(1)<fustrum(2)) || (fustrum(1)< modifiedZ(2)<fustrum(2)) || (fustrum(1)< modifiedZ(3)<fustrum(2))
            finalSceneData = [finalSceneData; modifiedSceneData(i,:)];     %add to final data
      %end
end
 
%%%%%%%%%%%%%%%%%%%%%%NORMALIZE LIGHTING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Find max Value
maxValArray = max(finalSceneData);
maxValArray = maxValArray(14:16)';
maxVal = max(maxValArray)
finalSceneData = [finalSceneData(:,1:13) finalSceneData(:,14:16)/maxVal];

%%%%%%%%%%%%%%%%%%%PRINT IMAGE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(finalSceneData)
      lighting = finalSceneData(i,14:16);
      triangle = [finalSceneData(i, 2:4); finalSceneData(i, 6:8); finalSceneData(i, 10:12)];
           
     patch(triangle(:,1), triangle(:,2), lighting, 'EdgeColor', 'none');
end