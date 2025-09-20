// --- パラメータ ---
L = 2.0;   H = 0.4;
xc = 0.2;  yc = 0.2;  R = 0.05;

// --- 長方形水路 ---
Point(1) = {0, 0, 0};
Point(2) = {L, 0, 0};
Point(3) = {L, H, 0};
Point(4) = {0, H, 0};
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};

// --- 円柱（中心点を先に！） ---
Point(1000) = {xc, yc, 0};
Point(10) = {xc+R, yc, 0};
Point(11) = {xc, yc+R, 0};
Point(12) = {xc-R, yc, 0};
Point(13) = {xc, yc-R, 0};
Circle(10) = {10, 1000, 11};
Circle(11) = {11, 1000, 12};
Circle(12) = {12, 1000, 13};
Circle(13) = {13, 1000, 10};

// --- 面（円孔付き） ---
Line Loop(20) = {1, 2, 3, 4};
Line Loop(21) = {10, 11, 12, 13};
Plane Surface(30) = {20, 21};

// --- 2D面メッシュ ---
Mesh.Algorithm = 6; // Frontal-Delaunay
Mesh.CharacteristicLengthMin = 0.005;
Mesh.CharacteristicLengthMax = 0.02;

thk = 1e-3;
out[] = Extrude {0, 0, thk} { Surface{30}; Layers{1}; Recombine; };

// 体積
Physical Volume("fluid") = { out[1] };

Physical Surface("front") = { 30 };      // z = 0 面（押し出し前の面）
Physical Surface("back") = { out[0] };  // z = thk 面（押し出し後の上面）

// 側面
Physical Surface("walls") = { out[2], out[4] };
Physical Surface("outlet") = { out[3] };
Physical Surface("inlet") = { out[5] };
Physical Surface("cylinder") = { out[6], out[7], out[8], out[9] };