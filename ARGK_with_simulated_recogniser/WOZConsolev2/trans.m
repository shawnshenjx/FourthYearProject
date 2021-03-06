
function [x,y,z] = trans(mPts,pHmd,qHmd,kbP,kbQ,hlPs,hlQs)

cal = [0.001203,-0.071733,-0.038141,-3.300962,-0.747955,1.157695];
estCalHT = ht4x4([cal(1) cal(2) cal(3)], quaternion([cal(4) cal(5) cal(6)],'eulerd','XYZ','frame'));

rbHT_final = ht4x4(pHmd,quaternion(qHmd));

[kbP_rh, kbQ_rh]  = lhPQ2rhPQ(kbP,kbQ);
kbHT = ht4x4(kbP_rh,kbQ_rh);

[hlP_final, hlQ_final]  = lhPQ2rhPQ(hlPs,hlQs);
hlHT_final = ht4x4(hlP_final,hlQ_final);

kbHT_cam = inv(inv(kbHT) * hlHT_final);


ot2kbHT = inv(rbHT_final * estCalHT * kbHT_cam);
mPtsKb = transformPts(ot2kbHT, mPts);

x=mPtsKb(1);
y=mPtsKb(2);
z=mPtsKb(3);
end

