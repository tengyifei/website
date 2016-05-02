---
title: PHP weak typing and floating-point troubles
published: 2014-05-09T14:27:18Z
categories: Computer Science,Web
tags: php
---

I was coding a PHP library to parse some RPC protocol. One of the steps involved decoding 64-bit signed Long numbers serialized over the Internet. The protocol encoded the Long number using [two's complement encoding](http://en.wikipedia.org/wiki/Two's_complement) and then converted it to BASE64\. I wrote the following function to convert the BASE64 number back to decimal:

```php
self::$TWO_TO_63 = pow(2,63);
self::$TWO_TO_64 = pow(2,64);

public static function base64toDecimal($base64){
    $digits = strlen($base64)-1;
    $multiplier = 1;
    $result = 0;
    while ($digits >= 0){
        $result += self::base64toDecSingle($base64[$digits]) * $multiplier;
        $multiplier *= 64;
        $digits--;
    }
    if ($result >= self::$TWO_TO_63){    //wrap around
        return ($result - self::$TWO_TO_64);
    }
    return $result;
}
```

Where base64toDecSingle is another function that takes a single BASE64 character and converts it to decimal format.

The algorithm starts from the least significant digit, adding each digit multiplied by an appropriate coefficient to the result. Because PHP doesn't allow integer overflow to happen, the variable $result will be automatically cast to floating-point when it gets too large, and can never wrap around, behaving more like a infinitely-large unsigned type. This, coupled with the fact that two's complement encoding is used, causes negative numbers to be erroneously converted to huge positive numbers as the signed Long is interpreted as an unsigned one. Hence special handling is applied when the function detects that the sign bit is one, which can be deduced from the number being larger than or equal to 2^63 (10000000.....<sub>2</sub>).

There are no apparent logical mistakes in the above code, but when it comes to testing, everything started to fall apart. I was getting -1 convert to 0, and a whole bunch of other terrible inaccuracies. After many hours of futile debugging (it is tempting to think that there is an off-by-one error which is not the case, given that -1 became 0), I narrowed down the source of error to PHP's floating-point implementation.To see the problem, let's first look at the underlying floating-point format used by PHP: IEEE 754 double-precision binary floating point. 

![Layout of bits usage in IEEE 754 double](http://upload.wikimedia.org/wikipedia/commons/thumb/a/a9/IEEE_754_Double_Floating_Point_Format.svg/618px-IEEE_754_Double_Floating_Point_Format.svg.png)

Layout of bits usage in IEEE 754 double [[1]](#ref1)

The entire representation occupies 64 bits, of which 54 bits are used to encode the significant digits in the floating-point number. This gives about log(2^52)≈15.7 meaningful digits. The implication is that when you add a very small number (e.g. 1) to a huge number, the change would be so minute that it cannot be represented by the format at all. Most implementations will return the best approximate, which in many cases will still be the original number. To test this, I wrote the following code:

```php
$large_number = pow(10, 20);   //over the limit within which the entire
                               //number can be represented digit-perfect
echo $large_number + 1 - $large_number;
```

Guess what the output is? That's right, _zero_!

With this limitation in mind, we can reexamine the previous piece of code, and spot the problem at line 14\. Since PHP follows the always-cast-to-float-when-overflow rule, negative numbers will inevitably become floating-point. Negative one, being decoded to 2^64 - 1 when interpreted as unsigned long, is well out of the range of numbers representable by PHP without loss of precision, and is basically equivalent to 2^64, which will yield zero upon further processing.

Fortunately, PHP provides several ways to handle huge numbers properly. One ways is through the bcmath functions, which provides arbitrary-precision arithmetic. The above function can be rewritten to take advantage of them, and nearly all conversion errors were eliminated:

```php
self::$TWO_TO_63 = bcpow('2', '63');
self::$TWO_TO_64 = bcpow('2', '64');

public static function base64toDecimal($base64){
    $digits = strlen($base64)-1;
    $multiplier = '1';
    $result = '0';
    while ($digits >= 0){
        $result = bcadd($result, bcmul(strval(self::base64toDecSingle($base64[$digits])), $multiplier));
        $multiplier = bcmul($multiplier, '64');
        $digits--;
    }
    if (bccomp($result, self::$TWO_TO_63)==1){    //wrap around
        return (float)(bcsub($result, self::$TWO_TO_64));
    }
    return (float)$result;
}
```

Notice that is still a single conversion to float happening at either line 14 or 16\. As PHP does not support operator overloading, there is no way to let existing code switch over from floating-point to arbitrary-precision arithmetic without rewriting all of them, so I might as well do the conversion here to preserve some consistency.

<a id="ref1"></a>[1] [http://en.wikipedia.org/wiki/Double-precision_floating-point_format](http://en.wikipedia.org/wiki/Double-precision_floating-point_format)
