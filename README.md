# ディレクトリ構成のイメージ

```
cylinder2D/
├─ channel_cylinder.geo          ← Gmsh用ジオメトリ
├─ mesh.msh                      ← （Gmsh出力で自動生成（3Dセルを含む .msh2））
├─ 0/
│  ├─ U                          ← 速度の初期・境界条件（inlet/outlet/walls/cylinder/front/back）
│  └─ p                          ← 圧力の初期・境界条件（同上）
├─ constant/
│  ├─ physicalProperties         ← 物性（Newtonian, ν）
│  ├─ turbulenceProperties       ← 乱流設定（laminar）
│  └─ polyMesh/                  ← （gmshToFoam で自動生成）
│     ├─ boundary
│     ├─ faces
│     ├─ neighbour
│     ├─ owner
│     └─ points
├─ system/
│  ├─ controlDict                ← 計算時間・書き出し間隔など
│  ├─ fvSchemes                  ← 時間・空間離散スキーム（ddt/div/grad/laplacian 等）
│  └─ fvSolution                 ← 連立方程式ソルバ設定（p/U, pFinal/UFinal を含む）
└─ log.icoFoam                   ← （実行ログ）

```

# コマンド手順

## メッシュ生成 → OpenFOAM 変換

```
cd ~/OpenFOAM/$USER-13/run/cylinder2D
```

既存生成物クリア（任意）

```
rm -rf constant/polyMesh mesh.msh
```

Gmsh: 押し出し付きの .geo から 3D メッシュを出力（msh2形式）

```
gmsh -3 channel_cylinder.geo -format msh2 -o mesh.msh
```

OpenFOAM 形式に変換（polyMesh 作成）

```
gmshToFoam mesh.msh
```

変換物の存在確認

```
ls constant/polyMesh
```

## パッチ型の整合（front/back=対称面）

パッチ型を一括で整える（.geo の物理名を想定）＊ここは丸ごとコピペ＊

```
awk '
/^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*$/ {name=$1}
$1=="type" {
  if (name=="front" || name=="back")           {$0="        type            symmetryPlane;"}
  else if (name=="walls" || name=="cylinder")  {$0="        type            wall;"}
  else if (name=="inlet" || name=="outlet")    {$0="        type            patch;"}
}
{print}
' constant/polyMesh/boundary > /tmp/b && mv /tmp/b constant/polyMesh/boundary
```

目視確認

```
grep -nA3 -E 'front|back|walls|cylinder|inlet|outlet' constant/polyMesh/boundary
```

## メッシュ健全性チェック

```
checkMesh
```

"Error" の文字列が出たらよく読む，"Warming" は無視で良いかも

## 計算

```
icoFoam | tee log.icoFoam
```

ここまでで 0.1 / 0.2 / ... のような出力タイムステップに応じたフォルダが作成されるはず

## 可視化

```
paraFoam
```
