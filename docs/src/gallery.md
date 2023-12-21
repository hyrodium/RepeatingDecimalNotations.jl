# Gallery

```@setup gallery
using RepeatingDecimalNotations
using RepeatingDecimalNotations: stringify, rationalify
```

## Long repeating decimals
```@repl gallery
stringify(1//7)
stringify(1//17)
stringify(1//97)
stringify(1//983)
stringify(1//4967)
```

## Fibonacchi subsequence in repeating part
```@repl gallery
stringify(1//89)
stringify(1//9899)
```

## Midy's theorem
```@repl gallery
stringify(1//7)
142 + 857
stringify(1//17)
05882352 + 94117647
stringify(1//19)
052631578 + 947368421
052631 + 578947 + 368421
```
