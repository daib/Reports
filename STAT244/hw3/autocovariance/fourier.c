#include <math.h>

#define PI	3.141592653589795
#define SWAP(a,b) tempr=(a);(a)=(b);(b)=tempr

// FFT 1D
void complexFFT(double* vector, unsigned int sampleRate, int sign)
{

	//variables for the fft
	unsigned long n, mmax, m, j, istep, i;
	double wtemp, wr, wpr, wpi, wi, theta, tempr, tempi;

	//binary inversion (note that the indexes 
	//start from 0 witch means that the
	//real part of the complex is on the even-indexes
	//and the complex part is on the odd-indexes)
	vector--;
	n = sampleRate << 1;
	j = 1;
	for (i = 1; i < n; i += 2)
	{
		if (j > i)
		{
			SWAP(vector[j],vector[i]);
			SWAP(vector[j+1],vector[i+1]);
		}
		m = n >> 1;
		while (m >= 2 && j > m)
		{
			j -= m;
			m >>= 1;
		}
		j += m;
	}
	//end of the bit-reversed order algorithm

	//Danielson-Lanzcos routine
	mmax = 2;
	while (n > mmax)
	{
		istep = mmax << 1;
		theta = sign * (2 * PI / mmax);
		wtemp = sin(0.5 * theta);
		wpr = -2.0 * wtemp * wtemp;
		wpi = sin(theta);
		wr = 1.0;
		wi = 0.0;
		for (m = 1; m < mmax; m += 2)
		{
			for (i = m; i <= n; i += istep)
			{
				j = i + mmax;
				tempr = wr * vector[j] - wi * vector[j+1];
				tempi = wr * vector[j+1] + wi * vector[j];
				vector[j] = vector[i] - tempr;
				vector[j+1] = vector[i+1] - tempi;
				vector[i] += tempr;
				vector[i+1] += tempi;
			}
			wr = (wtemp = wr) * wpr - wi * wpi + wr;
			wi = wi * wpr + wtemp * wpi + wi;
		}
		mmax = istep;
	}
	//end of the algorithm
}

double* prepareData(double data[], unsigned long numSamples, unsigned long* sampleRate)
{
	double* x;
	unsigned long i;
	//find the smallest integer power of 2 greater than n
	*sampleRate = 1;
	while (*sampleRate < numSamples)
	{
	    *sampleRate = *sampleRate << 1;
	}
	//the complex array is real+complex so the array
	//as a size n = 2* number of complex samples
	//real part is the data[index] and
	//the complex part is the data[index+1]

	x = (double*) malloc(sizeof(double) * (2 * (*sampleRate)));

	//put the real array in a complex array
	//the complex part is filled with 0's
	//the remaining vector with no data is filled with 0's
	for (i = 0; i < *sampleRate; i++)
	{
		if (i < numSamples)
			x[2 * i] = data[i];
		else
			x[2 * i] = 0;
		x[2 * i + 1] = 0;
	}

	return x;
}

