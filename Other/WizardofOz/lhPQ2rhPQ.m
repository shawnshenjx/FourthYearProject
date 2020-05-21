function [P,Q] = lhPQ2rhPQ(lhP,lhQ)


Q = quaternion([lhQ(1) lhQ(2) -lhQ(3) -lhQ(4)]);

P = lhP;
P(1) = -P(1);

end