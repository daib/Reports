#include "timer.h"

extern double* loadmat(char *fname, int* n, int* m);
extern void complexFFT(double vector[], unsigned int N, int sign);
extern double* prepareData(double data[], unsigned long numSamples,
        unsigned long* sampleRate);

#define DEFAULT_NUM_COVARIANCES	20

int main(int argc, char* argv[])
{
    double *xObs, *scaled_intensity, *normalC, *fftC, xMean, *X;

    unsigned int n, m, i, k, t, N, q, numCovariance, nSquare;

    if (argc > 1)
    {
        numCovariance = atoi(argv[1]);
    }
    else
        numCovariance = DEFAULT_NUM_COVARIANCES;

    xObs = loadmat("armasq.dat", &n, &m);

    n *= m; //get the number of osevations

    printf("Loaded %d numbers\n", n);

    TIME0;

    normalC = (double*) malloc(sizeof(double) * numCovariance);

    //compute the autocovariance using normal method
    //compute x mean
    xMean = 0;
    for (t = 0; t < n; t++)
    {
        xMean += xObs[t];
    }
    xMean /= n;

    for (k = 1; k <= numCovariance; k++)
    {
        normalC[k - 1] = 0;

        for (t = 0; t < n - k; t++)
        {
            normalC[k - 1] += ((xObs[t] - xMean) * (xObs[t + k] - xMean));
        }

        normalC[k - 1] /= n;
    }

    TIME1("\nComputation time of the normal method");

    TIME0
    //method using FFT
    //inverse FFT to find the intensities
    X = prepareData(xObs, n, &N);

    complexFFT(X, N, -1);

    //compute the periodogram
    //and prepare the c(t)
    //N is even now
    q = N / 2;
    scaled_intensity = (double*) malloc(sizeof(double) * N);
    nSquare = N * N;
    for (i = 1; i < q; i++)
    {
        k = 2 * (i - 1);
        scaled_intensity[i] = (X[k] * X[k] + X[k + 1] * X[k + 1]) / (nSquare);
    }

    scaled_intensity[0] = (xMean * xMean) / (4 * nSquare);
    scaled_intensity[q] = (X[2 * (q - 1)] * X[2 * (q - 1)]) / (4 * nSquare);

    //scale the intensity to use inverse FFT to derive autocovariance
    for (i = q + 1; i < N; i++)
    {
        scaled_intensity[i] = scaled_intensity[N - i];
    }

    fftC = prepareData(scaled_intensity, N, &N);
    complexFFT(fftC, N, 1);
    TIME1("\nComputation time of the FFT method");

    printf("Autocovariance\tNormal\t\tFFT\t\tError\n\n");
    for (i = 1; i <= numCovariance; i++)
    {
        printf("C(%d)\t\t%5E\t%5E\t%E\n", i, normalC[i - 1], fftC[2 * i], fabs(
                normalC[i - 1] - fftC[2 * i]));
    }

    free(scaled_intensity);
    free(normalC);
    free(fftC);
    free(X);
    free(xObs);

}
