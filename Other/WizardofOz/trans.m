function [mPtsKb] = trans(mPts,pHmd,qHmd,kbP,kbQ,hlPs,hlQs)


cal = [0.0   -0.04   0.05    0   0    0];
estCalHT = ht4x4([cal(1) cal(2) cal(3)], quaternion([cal(4) cal(5) cal(6)],'eulerd','XYZ','frame'));

rbHT_final = ht4x4(pHmd,quaternion(qHmd));

[kbP_rh, kbQ_rh]  = lhPQ2rhPQ(kbP,kbQ);
kbHT = ht4x4(kbP_rh,kbQ_rh);

[hlP_final, hlQ_final]  = lhPQ2rhPQ(hlPs,hlQs);
hlHT_final = ht4x4(hlP_final,hlQ_final);

kbHT_cam = inv(inv(kbHT) * hlHT_final);


ot2kbHT = inv(rbHT_final * estCalHT * kbHT_cam);
mPtsKb = transformPts(ot2kbHT, mPts);



end

