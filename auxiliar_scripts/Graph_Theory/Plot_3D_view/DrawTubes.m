function[] = DrawTubes(P1,P2,color)
    % Draw tube between two points (P1 and P2);
    % P1 = 1x3 vector
    % P2 = 1x3 vector
    % value is the width from 0 to 1;
    
    u = P2-P1;
    t = 0.5*null(u)';
    v = t(1,:); w = t(2,:);
    m = 32; n = 85;
    [S,T] = meshgrid(linspace(0,1,m),linspace(0,2*pi,n));
    S = S(:); T = T(:);
    P = repmat(P1,m*n,1) + S*u + cos(T)*v + sin(T)*w;
    X = reshape(P(:,1),n,m);
    Y = reshape(P(:,2),n,m);
    Z = reshape(P(:,3),n,m);
    surf(X,Y,Z,'FaceColor',color,'EdgeColor','none');

end