function ptsTrans = transformPts(m4x4, pts)

ptsTrans = m4x4 * [pts ones(size(pts,1),1)]';
ptsTrans = ptsTrans(1:3,:)';

end