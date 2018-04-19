# GDiffTool
Diff Array 
## OC diff比对库. 可输出2个数组增.删.改.移动. 用于批处理.
```objc
  self.oldArray = @[createTest(@"1", 3),createTest(@"1", 3),createTest(@"1", 3),createTest(@"3", 1),createTest(@"4", 1),createTest(@"6", 1),createTest(@"1", 3),createTest(@"1", 3),createTest(@"1", 3),createTest(@"3", 1),createTest(@"4", 1),createTest(@"6", 1),createTest(@"1", 3),createTest(@"1", 3),createTest(@"1", 3),createTest(@"3", 1),createTest(@"4", 1),createTest(@"6", 1)];
  self.nArray = @[createTest(@"1", 1),createTest(@"1", 1),createTest(@"1246", 3),createTest(@"4234", 1)];  
```

```
  GDiffCore *diff = [GDiffCore new];
  GDiffResult *result = [diff diff:self.oldArray newArray:self.nArray];
```
