function [az_new, el_new] = getViewAngles(hAxes, o)

az_new=0; 
el_new=0;

if isempty(o)
    return;
end

cp0 = get(hAxes, 'CameraPosition');
ct0 = get(hAxes, 'CameraTarget');

% Translate ct to (0,0,0)
v = cp0 - ct0;
x = v(1);
y = v(2);
z = v(3);
Vaxis = [x,y,z];

% Make sure we are dealing with a righ handed coordinate system
if leftRightFlipped(o)
    o = [o(2), o(1), o(3)];
end

%%%%%%%%%% Variables U, Vp, SI, RL
% U : the projection of view axis to the RL-AP plane.
% Vp: a vector along the P axis with length equal to view axis. 
% SI: the value of this var is the magnitude of the XYZ axis corresponding to
%     the SI axis
% RL: the value of this var is the magnitude of the XYZ axis corresponding to
%     the RL axis.
% 


% Dealing only with right-handed systems means we only have to consider 24
% orientations instead of 48 total possibilities
switch(upper(o))
    
    case 'RAS'
        
        % elevation angle: RL-AP plane corresponds to XY plane
        U  = [x, y, 0];
        SI = z;
        
        % azimuth angle: axis in the xyz system corresponding to P is -Y. 
        Vp = [0, -sqrt(x^2 + y^2), 0];
        RL = x;

    case 'RPI'
        
        % elevation angle: RL-AP plane corresponds to XY plane
        U  = [x, y, 0];
        SI = -z;
        
        % azimuth angle: axis in the xyz system corresponding to P is +Y. 
        Vp = [0, sqrt(x^2 + y^2), 0];
        RL = x;

    case 'RSP'
        
        % elevation angle: RL-AP plane corresponds to XZ plane
        U  = [x, 0, z];
        SI = y;
        
        % azimuth angle: axis in the xyz system corresponding to P is +Z. 
        Vp = [0, 0, sqrt(x^2 + z^2)];
        RL = x;

    case 'RIA'
        
        % elevation angle: RL-AP plane corresponds to XZ plane
        U  = [x, 0, z];
        SI = -y;
        
        % azimuth angle: axis in the xyz system corresponding to P is -Z. 
        Vp = [0, 0, -sqrt(x^2 + z^2)];
        RL = x;


    case 'LAI'
        
        % elevation angle: RL-AP plane corresponds to XZ plane
        U  = [x, y, 0];
        SI = -z;
        
        % azimuth angle: axis in the xyz system corresponding to P is -Y.
        Vp = [0, -sqrt(x^2 + y^2), 0];
        RL = -x;

    case 'LPS'
        
        % elevation angle: RL-AP plane corresponds to XY plane
        U  = [x, y, 0];
        SI = z;
        
        % azimuth angle: axis in the xyz system corresponding to P is +Y. 
        Vp = [0, sqrt(x^2 + y^2), 0];
        RL = -x;

    case 'LSA'
        
        % elevation angle: RL-AP plane corresponds to XZ plane
        U  = [x, 0, z];
        SI = y;
        
        % azimuth angle: axis in the xyz system corresponding to P is -Z. 
        Vp = [0, 0, -sqrt(x^2 + z^2)];
        RL = -x;

    case 'LIP'
        
        % elevation angle: RL-AP plane corresponds to XZ plane
        U  = [x, 0, Z];
        SI = -y;
        
        % azimuth angle: axis in the xyz system corresponding to P is +Z.
        Vp = [0, 0, sqrt(x^2 + Z^2)];
        RL = -x;

    case 'ARI'
        
        % elevation angle: RL-AP plane corresponds to XY plane
        U  = [x, y, 0];
        SI = -z;
        
        % azimuth angle: axis in the xyz system corresponding to P is -X.
        Vp = [-sqrt(x^2 + y^2), 0, 0];
        RL = y;

    case 'ALS'
        
        % elevation angle: RL-AP plane corresponds to XY plane
        U  = [x, y, 0];
        SI = z;
        
        % azimuth angle: axis in the xyz system corresponding to P is -X. 
        Vp = [-sqrt(x^2 + y^2), 0, 0];
        RL = -y;

    case 'ASR'
        
        % elevation angle: RL-AP plane corresponds to XZ plane
        U  = [x, 0, z];
        SI = y;
        
        % azimuth angle: axis in the xyz system corresponding to P is -X.
        Vp = [-sqrt(x^2 + z^2), 0, 0];
        RL = z;

    case 'AIL'
        
        % elevation amgle: RL-AP plane corresponds to XZ plane
        U  = [x, 0, z];
        SI = -y;
        
        % azimuth angle: axis in the xyz system corresponding to P is -X. 
        Vp = [-sqrt(x^2 + z^2), 0, 0];
        RL = -z;

    case 'PRS'
        
        % elevation amgle: RL-AP plane corresponds to XY plane
        U  = [x, y, 0];
        SI = z;
        
        % azimuth angle: axis in the xyz system corresponding to P is +X. 
        Vp = [sqrt(x^2 + y^2), 0, 0];
        RL = y;

    case 'PLI'
        
        % elevation amgle: RL-AP plane corresponds to XY plane
        U  = [x, y, 0];
        SI = -z;
        
        % azimuth angle: axis in the xyz system corresponding to P is +X. 
        Vp = [sqrt(x^2 + y^2), 0, 0];
        RL = -y;

    case 'PSL'
        
        % elevation amgle: RL-AP plane corresponds to XZ plane
        U  = [x, 0, z];
        SI = y;
        
        % azimuth angle: axis in the xyz system corresponding to P is +X.
        Vp = [sqrt(x^2 + z^2), 0, 0];
        RL = -z;

    case 'PIR'
        
        % elevation amgle: RL-AP plane corresponds to XZ plane
        U  = [x, 0, z];
        SI = -y;
        
        % azimuth angle: axis in the xyz system corresponding to P is +X.
        Vp = [sqrt(x^2 + z^2), 0, 0];
        RL = z;


    case 'SRA'
        
        % elevation amgle: RL-AP plane corresponds to YZ plane
        U  = [0, y, z];
        SI = x;
        
        % azimuth angle: axis in the xyz system corresponding to P is -Y.
        Vp = [0, 0, -sqrt(y^2 + z^2)];
        RL = y;

    case 'SLP'
        
        % elevation amgle: RL-AP plane corresponds to YZ plane
        U  = [0, y, z];
        SI = x;
        
        % azimuth angle: axis in the xyz system corresponding to P is +Z.
        Vp = [0, 0, sqrt(y^2 + z^2)];
        RL = -y;

    case 'SAL'
        
        % elevation amgle: RL-AP plane corresponds to YZ plane
        U  = [0, y, z];
        SI = x;
        
        % azimuth angle: axis in the xyz system corresponding to P is -Y. 
        Vp = [0, -sqrt(y^2 + z^2), 0];
        RL = -z;

    case 'SPR'
        
        % elevation angle: RL-AP plane corresponds to YZ plane
        U  = [0, y, z];
        SI = x;
        
        % azimuth angle: axis in the xyz system corresponding to P is +Y. 
        Vp = [0, sqrt(y^2 + z^2), 0];
        RL = z;

        
    case 'IRP'
        
        % elevation amgle: RL-AP plane corresponds to YZ plane
        U  = [0, y, z];
        SI = -x;
        
        % azimuth angle: axis in the xyz system corresponding to P is +Z. 
        Vp = [0, 0, sqrt(y^2 + z^2)];
        RL = y;

    case 'ILA'

        % elevation amgle: RL-AP plane corresponds to YZ plane
        U  = [0, y, z];
        SI = -x;
    
        % azimuth amgle: axis in the xyz system corresponding to P is -Z. 
        Vp = [0, 0, -sqrt(y^2 + z^2)];
        RL = -y;
                
    case 'IAR'
        
        % elevation amgle: RL-AP plane corresponds to YZ plane
        U  = [0, y, z];
        SI = -x;
    
        % azimuth amgle: axis in the xyz system corresponding to P is -Y. 
        Vp = [0, -sqrt(y^2 + z^2), 0];
        RL = z;
                
    case 'IPL'
        
        % elevation amgle: RL-AP plane corresponds to YZ plane
        U  = [0, y, z];
        SI = -x;
    
        % azimuth angle: axis in the xyz system corresponding to P is +Y.
        Vp = [0, sqrt(y^2 + z^2), 0];
        RL = -z;

end

if SI > 0
    el_new =  angleBetweenVectors(U, Vaxis);
else
    el_new = -angleBetweenVectors(U, Vaxis);
end
if RL > 0
    az_new = angleBetweenVectors(Vp, U);
else
    az_new = -angleBetweenVectors(Vp, U);
end


if abs(az_new) < 1e-3
    az_new=0;
end
if abs(el_new) < 1e-3
    el_new=0;
end

