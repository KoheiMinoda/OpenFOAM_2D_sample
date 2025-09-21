// --- パラメータ ---
L = 2.0;   H = 0.4;
xc = 0.2;  yc = 0.2;  R = 0.05;

// --- 長方形水路 ---
Point(1) = {0, 0, 0};
Point(2) = {L, 0, 0};
Point(3) = {L, H, 0};
Point(4) = {0, H, 0};
Line(1) = {1, 2}; // Line で 1 と 2 をつなぐ
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};

// --- 円柱（中心点を先に！） ---
Point(1000) = {xc, yc, 0}; // 中心点
Point(10) = {xc+R, yc, 0}; // 右側の円周点
Point(11) = {xc, yc+R, 0}; // 上側の円周点
Point(12) = {xc-R, yc, 0}; // 左側の円周点
Point(13) = {xc, yc-R, 0}; // 下側の円周点
Circle(10) = {10, 1000, 11}; // Circle で 1000 を中心に 10 と 11 をつなぐ
Circle(11) = {11, 1000, 12};
Circle(12) = {12, 1000, 13};
Circle(13) = {13, 1000, 10};

// --- 面（円孔付き） ---
Line Loop(20) = {1, 2, 3, 4}; // 1~4 を Loop させる
Line Loop(21) = {10, 11, 12, 13}; // 10~13 を Loop させる
Plane Surface(30) = {20, 21}; // 20,21 で平面を作成する

// --- 2D面メッシュ ---
Mesh.Algorithm = 6; // メッシュ作成のアルゴリズム: Frontal-Delaunay
Mesh.CharacteristicLengthMin = 0.005; // 要素サイズの下限
Mesh.CharacteristicLengthMax = 0.02; // 要素サイズの上限

thk = 1e-3; // 押し出しの厚み
// 面 30 を Z 方向に厚み thk で一層押し出して四角化
out[] = Extrude {0, 0, thk} { Surface{30}; Layers{1}; Recombine; };

// --- OpenFOAM パッチ名 / 領域目の割り当て ---
// out[] の中身は，体積 / 上からの定義順で生成されていく
// out[1]: 体積，out[2]: Line 1, ...

// 体積
Physical Volume("fluid") = { out[1] }; // 押し出しで生成された体積 out[1] を流体領域 "fluid" に

Physical Surface("front") = { 30 }; // z=0：押し出し前の平面を "front" パッチに
Physical Surface("back") = { out[0] };  // z=thk, out[0] の平面を "back" パッチに

// 側面
Physical Surface("walls") = { out[2], out[4] }; // Line 1 と Line 3 を "walls" に
Physical Surface("outlet") = { out[3] }; // Line 3 を "outlet" に
Physical Surface("inlet") = { out[5] }; // Line 5 を "inlet" に
Physical Surface("cylinder") = { out[6], out[7], out[8], out[9] }; // Circle 10~13 を "cylinder" に
