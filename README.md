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

パッチ型を一括で整える（.geo の物理名を想定）

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
