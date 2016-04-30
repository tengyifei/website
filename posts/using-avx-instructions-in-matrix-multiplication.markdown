---
title: Using AVX instructions in matrix multiplication
published: 2014-02-28T04:06:40Z
categories: Computer Science,Mathematics
tags: assembler,AVX,C++,intrinsics,matrix,vector
---

<p>Recent Intel processors such as SandyBridge and IvyBridge have incorporated an instruction set called Advanced Vector Extensions, or AVX. This new addition to the spectrum of SIMD instructions makes the CPU even faster at crunching large amounts of floating point data. Matrix multiplication is a great candidate for performing optimizations via SIMD, since it involves mutually-independent multiplication and summing. To take advantage of the speed up, one could certainly inline a couple of assembly instructions. But this method is both inelegant and non-portable. The preferred approach is to use intrinsics instead. </p>
<p>What are instrinsics? Loosely speaking, intrinsics are functions that provide functionality equivalent to a few lines of assembly. Hence the assembly version can serve as a drop-in replacement to the function at compile-time. This allows performance-critical assembly code to be inlined without sacrificing the beauty and readability of the high-level language syntax. For example, the intrinsic function <span class="inlinecode">InterlockedExchange(LONG volatile *target, LONG value)</span> atomically sets the data at the memory address held by target to value. This function will be replaced by a single inlined assembly <span class="inlinecode">xchg [target], value</span> during compile time. </p>
<p><!--more-->The <a title="Intel Intrinsics Guide" href="http://software.intel.com/sites/landingpage/IntrinsicsGuide/" target="_blank">Intel Intrinsics Guide</a> provides detailed reference on SIMD instructions and their respective intrinsic versions. However, the GCC naming conventions for intrinsic functions are different from those used in Intel, hence additional lookups are required. </p>
<p>There are three types of instructions used: <br />load: moving data from memory to registers for calculation<br />arithmetic: batch operation on floating-point numbers in registers<br />and finally, store: moving data from registers back to memory for future processing</p>
<p>The respective instructions are listed below:[table class="table table-striped"]<br />
Kind, Assembly, Description, GCC intrinsics<br />
load, "vmovups dst, addr", "Load 256-bits (composed of 8 packed single-precision (32-bit) floating-point elements) from memory into dst.", __builtin_ia32_loadups256<br />
mul, "vmulps dst, a, b", "Multiply packed single-precision (32-bit) floating-point elements in a and b, and store the results in dst.", __builtin_ia32_mulps256<br />
add, "vaddps dst, a, b", "Add packed single-precision (32-bit) floating-point elements in a and b, and store the results in dst.", __builtin_ia32_addps256<br />
store, "vmovups addr, a", "Store 256-bits (composed of 8 packed single-precision (32-bit) floating-point elements) from a into memory.", __builtin_ia32_storeups256<br />
[/table]</p>
<p>Using the instrinsic versions, one could write vectorized code with ease. The following is a simple example of multiplying two groups of 8 floats: </p>
<pre class="lang:c++" toolbar="false">#include
#include <iostream>
extern "C" {
#include <immintrin.h>
}

int main(){
	__m256 ymm0, ymm1;			//define the registers used
	float a[8]={1,2,3,4,5,6,7,8};
	float b[8]={2,3,4,5,6,7,8,9};
	float c[8];
	ymm0 = __builtin_ia32_loadups256(a);	//load the 8 floats in a into ymm0
	ymm1 = __builtin_ia32_loadups256(b);	//load the 8 floats in b into ymm1

	//multiply ymm0 and ymm1, store the result in ymm0
	ymm0 = __builtin_ia32_mulps256(ymm0, ymm1);
	__builtin_ia32_storeups256(c, ymm0);	//copy the 8 floats in ymm0 to c

	for (int i=0; i<8; i++)
		std::cout<<c[i]<<", ";
	return 0;
}</pre><!--raw--><p>Note that the header <span class="inlinecode">&lt;immintrin.h&gt;</span> must be included.</p><!--/raw-->
<p>Compile with:</p>
<pre toolbar="false">g++ -mavx main.cpp -o test</pre>
<p>The -mavx switch enables gcc to emit avx instructions. Without it, the program will not compile. Once run, the program should output "2, 6, 12, 20, 30, 42, 56, 72,". </p>
<p>To keep it simple, I first started with a reduced version of matrix multiplication: multiplying an n x m matrix with an m x 1 matrix, which is essentially a vector. E.g.</p>
<p><img style="display:block; margin-left:auto; margin-right:auto; border-radius: 0px; box-shadow: none;" alt="Matrix multiplication equation" src="https://static.thinkingandcomputing.com/2014/02/CodeCogsEqn.png" width="222" height="86" /></p>
<p><span>This is achieved by setting the element of the last matrix at the i</span><sup>th</sup><span style="line-height: 1.714285714; font-size: 1rem;"> row and j</span><sup>th</sup><span> column to be the dot product between i</span><sup>th</sup><span> row of the first matrix and j</span><sup>th</sup><span> column of the second matrix. </span></p>
<p>To do the same process efficiently using AVX code, one could load up to 8 groups of 8 floats per matrix in an iteration, using the <span class="inlinecode">__builtin_ia32_loadups256</span> function, after which respective float numbers in the two matrix would be multiplied, and the results summed to give the dot product. The advantage of this approach is that there is prospect of further instruction-level parallelism and also less overhead in loop. </p>
<p>[expand title="Click to expand full code"]</p>
<pre lang="C++" title="main.cpp">#include <iostream>
#include <time.h>
extern "C"
{
#include <immintrin.h>
}

using namespace std;

int main(){
  const int col = 128, row = 24, num_trails = 10000000;

  float w[row][col];
  float x[col];
  float y[row];
  float scratchpad[8];
  for (int i=0; i<row; i++) {
    for (int j=0; j<col; j++) {
      w[i][j]=(float)(rand()%1000)/800.0f;
    }
  }
  for (int j=0; j<col; j++) {
    x[j]=(float)(rand()%1000)/800.0f;
  }

  clock_t t1, t2;

  t1 = clock();
  for (int r = 0; r < num_trails; r++)
    for(int j = 0; j < row; j++)
    {
      float sum = 0;
      float *wj = w[j];

      for(int i = 0; i < col; i++)
        sum += wj[i] * x[i];

      y[j] = sum;
    }
  t2 = clock();
  float diff = (((float)t2 - (float)t1) / CLOCKS_PER_SEC ) * 1000;
  cout<<"Time taken: "<<diff<<endl;

  for (int i=0; i<row; i++) {
    cout<<y[i]<<", ";
  }
  cout<<endl;

  __m256 ymm0, ymm1, ymm2, ymm3, ymm4, ymm5, ymm6, ymm7,
    ymm8, ymm9, ymm10, ymm11, ymm12, ymm13, ymm14, ymm15;

  t1 = clock();
  const int col_reduced = col - col%64;
  const int col_reduced_32 = col - col%32;
  for (int r = 0; r < num_trails; r++)
    for (int i=0; i<row; i++) {
      float res = 0;
      for (int j=0; j<col_reduced; j+=64) {
        ymm8 = __builtin_ia32_loadups256(&x[j]);
        ymm9 = __builtin_ia32_loadups256(&x[j+8]);
        ymm10 = __builtin_ia32_loadups256(&x[j+16]);
        ymm11 = __builtin_ia32_loadups256(&x[j+24]);
        ymm12 = __builtin_ia32_loadups256(&x[j+32]);
        ymm13 = __builtin_ia32_loadups256(&x[j+40]);
        ymm14 = __builtin_ia32_loadups256(&x[j+48]);
        ymm15 = __builtin_ia32_loadups256(&x[j+56]);

        ymm0 = __builtin_ia32_loadups256(&w[i][j]);
        ymm1 = __builtin_ia32_loadups256(&w[i][j+8]);
        ymm2 = __builtin_ia32_loadups256(&w[i][j+16]);
        ymm3 = __builtin_ia32_loadups256(&w[i][j+24]);
        ymm4 = __builtin_ia32_loadups256(&w[i][j+32]);
        ymm5 = __builtin_ia32_loadups256(&w[i][j+40]);
        ymm6 = __builtin_ia32_loadups256(&w[i][j+48]);
        ymm7 = __builtin_ia32_loadups256(&w[i][j+56]);

        ymm0 = __builtin_ia32_mulps256(ymm0, ymm8 );
        ymm1 = __builtin_ia32_mulps256(ymm1, ymm9 );
        ymm2 = __builtin_ia32_mulps256(ymm2, ymm10);
        ymm3 = __builtin_ia32_mulps256(ymm3, ymm11);
        ymm4 = __builtin_ia32_mulps256(ymm4, ymm12);
        ymm5 = __builtin_ia32_mulps256(ymm5, ymm13);
        ymm6 = __builtin_ia32_mulps256(ymm6, ymm14);
        ymm7 = __builtin_ia32_mulps256(ymm7, ymm15);

        ymm0 = __builtin_ia32_addps256(ymm0, ymm1);
        ymm2 = __builtin_ia32_addps256(ymm2, ymm3);
        ymm4 = __builtin_ia32_addps256(ymm4, ymm5);
        ymm6 = __builtin_ia32_addps256(ymm6, ymm7);
        ymm0 = __builtin_ia32_addps256(ymm0, ymm2);
        ymm4 = __builtin_ia32_addps256(ymm4, ymm6);
        ymm0 = __builtin_ia32_addps256(ymm0, ymm4);

        __builtin_ia32_storeups256(scratchpad, ymm0);
        for (int k=0; k<8; k++)
          res += scratchpad[k];
      }
      for (int j=col_reduced; j<col_reduced_32; j+=32) {
        ymm8 = __builtin_ia32_loadups256(&x[j]);
        ymm9 = __builtin_ia32_loadups256(&x[j+8]);
        ymm10 = __builtin_ia32_loadups256(&x[j+16]);
        ymm11 = __builtin_ia32_loadups256(&x[j+24]);

        ymm0 = __builtin_ia32_loadups256(&w[i][j]);
        ymm1 = __builtin_ia32_loadups256(&w[i][j+8]);
        ymm2 = __builtin_ia32_loadups256(&w[i][j+16]);
        ymm3 = __builtin_ia32_loadups256(&w[i][j+24]);

        ymm0 = __builtin_ia32_mulps256(ymm0, ymm8 );
        ymm1 = __builtin_ia32_mulps256(ymm1, ymm9 );
        ymm2 = __builtin_ia32_mulps256(ymm2, ymm10);
        ymm3 = __builtin_ia32_mulps256(ymm3, ymm11);

        ymm0 = __builtin_ia32_addps256(ymm0, ymm1);
        ymm2 = __builtin_ia32_addps256(ymm2, ymm3);
        ymm0 = __builtin_ia32_addps256(ymm0, ymm2);

        __builtin_ia32_storeups256(scratchpad, ymm0);
        for (int k=0; k<8; k++)
          res += scratchpad[k];
      }
      for (int l=col_reduced_32; l<col; l++) {
        res += w[i][l] * x[l];
      }
      y[i] = res;
    }
  t2 = clock();
  diff = (((float)t2 - (float)t1) / CLOCKS_PER_SEC ) * 1000;
  cout<<"Time taken: "<<diff<<endl;

  for (int i=0; i<row; i++) {
    cout<<y[i]<<", ";
  }
  cout<<endl;

  return 0;
}</pre>
<p>[/expand]</p>
<p><br />This algorithm has three versions of matrix-vector multiplication, namely the SIMD version using all YMM registers which handles column number up to the greatest multiple of 64, a similar version using half the registers handling the remaining column number up to the greatest multiple of 32, and a simple loop-based approach catering to the rest of situations.</p>
<p>Compile with:</p>
<pre toolbar="false">g++ -O3 -mavx main.cpp -o avxtest</pre>
<p>Running avxtest:</p>
<pre toolbar="false" highlight="false">$ ./avxtest
Time taken for serial version: 3980
5831.11, 6747, 6506.54, 6451.99, 5929.76, 6637.35,
Time taken for AVX version: 510
5831.11, 6747, 6506.54, 6451.99, 5929.76, 6637.35,</pre>
<p>As seen from the timing, using AVX resulted in nearly 8x speed up, which is expected, as each instruction is able to multiply 8 floats in a row. On the contrary, the serial multiplication algorithm, even under maximum optimization settings, was not automatically vectorized by gcc. </p>
<p><!--raw--><style type="text/css">
.inlinecode{
border: 1px solid #ddd; background-color: #f8f8f8; border-radius: 3px; font-family: Consolas, Courier, monospace; font-size: 12px;
}
</style>
<script type="text/javascript">jQuery(document).on('ready pjax:success', function() {
jQuery('.collapseomatic:not(.colomat-close)').each(function(index) {
		var thisid = jQuery(this).attr('id');
		jQuery('#target-'+thisid).css('display', 'none');
	});
});</script><!--/raw--></p>


