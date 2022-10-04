function [cp_new, v_up] = setViewAngles(hAxes, o, az, el)

cp0 = get(hAxes, 'CameraPosition');
ct0 = get(hAxes, 'CameraTarget');

[cp_new, v_up] = calcViewAxis(cp0, ct0, az, el, o);

set(hAxes, 'CameraPosition',cp_new);
cp_new = round(cp_new); ct = round(ct0);

