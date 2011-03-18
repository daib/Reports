//leader.cpp

#include <stdio.h>
#include <stdlib.h>
#include <list>
#include <math.h>

using namespace std;

#define MAX_LINE	256
#define DEFAULT_THRESHOLD	500	

#define DEFAULT_DATA_FILE "crime"

class DataPoint
{
public:
    DataPoint(int numVal)
    {
        val = new double[numVal];
    }
    ;

    ~DataPoint()
    {
        delete val;
    }
    ;

    //int city, murder, rape, robbery, assault, burglary, larceny, autotheft;
    double* val;
};

struct Cluster
{
    Cluster(int numVal) :
        centroid(numVal)
    {
    }
    list<DataPoint*> DataPoints;
    DataPoint centroid;
    double sumOfSquares;
};

double DISTANCE(DataPoint* x, DataPoint* y, int numCategories)
{
    double sum = 0;
    for (int i = 1; i < numCategories; i++)
    {
        sum += (x->val[i] - y->val[i]) * (x->val[i] - y->val[i]);
    }

    return sqrt(sum);
}

list<DataPoint*>* load(char* dataFile, int* numCategories)
{
    printf("Using data file: %s\n", dataFile);

    //parse the data file
    FILE* f = NULL;
    int ncol = 0;

    f = fopen(dataFile, "r");
    if (f == NULL)
    {
        printf("Cannot open the data file, exiting\n");
        exit(1);
    }

    char line[MAX_LINE];

    double val;

    //read the first line to get then number of categories

    fgets(line, MAX_LINE, f);

    int i = 0;
    while (line[i] != 0 && line[i] != '\n')
    {
        if (sscanf(line + i, "%lf", &val))
            ncol++;
        if (line[i] == ' ')
            while (line[i++] == ' ')
                ;
        for (; line[i] != 0 && line[i] != '\n'; i++)
            if (line[i] == ' ')
                break;
        while (line[i] == ' ')
            i++;
    }

    *numCategories = ncol;

    list<DataPoint*>* pDataPoints = new list<DataPoint*> ();

    rewind(f);

    while (fscanf(f, "%lf", &val) != EOF)
    {
        DataPoint* pDataPoint = new DataPoint(ncol);
        pDataPoints->push_back(pDataPoint);

        pDataPoint->val[0] = val;
        for (i = 1; i < ncol; i++)
        {
            if (fscanf(f, "%lf", &(pDataPoint->val[i])) == EOF)
                goto END_WHILE;
        }
    }
    END_WHILE: fclose(f);

    return pDataPoints;
}

void computeCentroidAndSumSquares(Cluster* pCluster, int numCategories)
{
    double* val = new double[numCategories];

    for (int i = 1; i < numCategories; i++)
        val[i] = 0;

    for (list<DataPoint*>::iterator it = pCluster->DataPoints.begin(); it
            != pCluster->DataPoints.end(); it++)
    {
        for (int i = 1; i < numCategories; i++)
        {
            val[i] += (*it)->val[i];
        }
    }

    for (int i = 1; i < numCategories; i++)
    {
        pCluster->centroid.val[i] = val[i] / pCluster->DataPoints.size();
        val[i] = 0;
    }

    //compute the sum of squares
    for (list<DataPoint*>::iterator it = pCluster->DataPoints.begin(); it
            != pCluster->DataPoints.end(); it++)
    {
        for (int i = 1; i < numCategories; i++)
        {
            val[i] += ((*it)->val[i] - pCluster->centroid.val[i])
                    * ((*it)->val[i] - pCluster->centroid.val[i]);
        }
    }

    for (int i = 1; i < numCategories; i++)
    {
        pCluster->sumOfSquares = val[i];
    }
    delete val;
}

//kmeans algorithms
list<Cluster*>* kmeans(list<Cluster*>* pClusters, int numCategories)
{

    list<Cluster*>::iterator it;

    bool converge = false;

    //compute the centroid
    for (it = pClusters->begin(); it != pClusters->end(); it++)
        computeCentroidAndSumSquares(*it, numCategories);

    while (!converge)
    {
        converge = true;

        for (it = pClusters->begin(); it != pClusters->end(); it++)
        {
            if ((*it)->DataPoints.size() <= 1)
                continue;

            list<Cluster*>::iterator toCluster;

            //pick one data point at each cluster
            for (list<DataPoint*>::iterator itc = (*it)->DataPoints.begin(); itc
                    != (*it)->DataPoints.end(); itc++)
            {
                //compute the distance to all the centroid points
                double dThis = DISTANCE(&((*it)->centroid), (*itc), numCategories);
                double newDistance = dThis * dThis * ((*it)->DataPoints.size())
                        / ((*it)->DataPoints.size() - 1);
                double smallestDistance = -1;

                for (list<Cluster*>::iterator it2 = pClusters->begin(); it2
                        != pClusters->end(); it2++)
                {
                    if (it2 != it)
                    {
                        double dOther = DISTANCE(&((*it2)->centroid), (*itc),
                                numCategories);
                        double otherDistance = dOther * dOther
                                * ((*it2)->DataPoints.size())
                                / ((*it2)->DataPoints.size() + 1);

                        if (newDistance > otherDistance)
                        {
                            if (smallestDistance == -1 || smallestDistance
                                    > otherDistance)
                            {
                                smallestDistance = otherDistance;
                                toCluster = it2;
                            }
                        }
                    }
                }

                if (smallestDistance != -1)
                {
                    //move to the closest cluster
                    (*it)->DataPoints.erase(itc);
                    (*toCluster)->DataPoints.push_back(*itc);

                    //recompute the centroid and sum and squares of the two clusters
                    computeCentroidAndSumSquares(*it, numCategories);
                    computeCentroidAndSumSquares(*toCluster, numCategories);

                    converge = false; //not yet converge
                    break;
                }
            }
        }
    }

    return pClusters;
}

//leader algorithm routine
list<Cluster*>* leader(list<DataPoint*>* pDataPoints, double threshold,
        int numCategories)
{
    printf("Threshold:\t %lf\n", threshold);

    list<DataPoint*> data(*pDataPoints);

    //leader clustering algorithm

    list<Cluster*>* pClusters = new list<Cluster*> ();
    list<Cluster*>& clusters = *pClusters;

    //choose the first set of data is the first leader of a cluster
    Cluster* pCluster = new Cluster(numCategories);
    pCluster->DataPoints.push_back(data.front());
    data.pop_front();

    clusters.push_back(pCluster);

    while (data.size() > 0)
    {
        double min = -1;

        list<Cluster*>::iterator closestCluster;
        list<Cluster*>::iterator it;
        DataPoint* nextPoint = data.front();
        data.pop_front();

        //find the closest cluster to the new point
        for (it = clusters.begin(); it != clusters.end(); it++)
        {
            //compare the distance with the first data point (the leader) of each cluster
            if ((min == -1) || (DISTANCE((*it)->DataPoints.front(), nextPoint,
                    numCategories) < min))
            {
                closestCluster = it;
                min = DISTANCE((*it)->DataPoints.front(), nextPoint, numCategories);
            }
        }

        //printf("Min = %d \n", min);

        if (min <= threshold)
        {
            //assign the observation to the closest cluster
            (*closestCluster)->DataPoints.push_back(nextPoint);
        }
        else
        {
            //if the closest cluster is still outside the cluster
            //create a new cluster with that new point is the leader
            pCluster = new Cluster(numCategories);
            pCluster->DataPoints.push_back(nextPoint);

            clusters.push_back(pCluster);
        }
    }

    return pClusters;
}

int main(int argc, char* argv[])
{

    //int city, murder, rape, robbery, assault, burglary, larceny, autotheft;

    double threshold = DEFAULT_THRESHOLD;
    bool useKmeans = true;

    char* dataFile = (char*) DEFAULT_DATA_FILE;

    if (argc > 1)
    {
        threshold = atof(argv[1]);
    }

    if (argc > 2)
    {
        char input = argv[2][0];
        if (input == 't' || input == 'T')
        {
            useKmeans = true;
        }
        else if (input == 'f' || input == 'F')
        {
            useKmeans = false;
        }
        else
            printf("Invalid value for use k-means or not \n");
    }

    if (argc > 3)
    {
        dataFile = argv[3];
    }

    int numCategories;

    //load data
    list<DataPoint*>* pDataPoints = load(dataFile, &numCategories);

    //leader algorithm
    list<Cluster*>* pClusters = leader(pDataPoints, threshold, numCategories);

    //k-mean
    if (useKmeans)
    {
        printf("Using k-means\n");
        kmeans(pClusters, numCategories);
    }
    else
        printf("Not using k-means\n");

    int count = 1;
    double totalSum = 0;

    while (pClusters->size() > 0)
    {
        Cluster* pCluster = pClusters->front();
        pClusters->pop_front();

        computeCentroidAndSumSquares(pCluster, numCategories);

        printf("\n\nCluster %d-th with sum of squares %lf", count,
                pCluster->sumOfSquares);
        totalSum += pCluster->sumOfSquares;

        while (pCluster->DataPoints.size() > 0)
        {
            DataPoint* pDataPoint = pCluster->DataPoints.front();
            pCluster->DataPoints.pop_front();
            printf("\n City %5d Values: ", (int) (pDataPoint->val[0]));
            for (int i = 1; i < numCategories; i++)
            {
                printf("%f ", pDataPoint->val[i]);
            }
        }

        delete pCluster;

        count++;
    }

    printf("\n\nThere are %d clusters\n\n", count);

    delete pClusters;

    while (pDataPoints->size() > 0)
    {
        DataPoint* pDataPoint = pDataPoints->back();
        delete pDataPoint;
        pDataPoints->pop_back();
    }

    delete pDataPoints;

    printf("\nThe total sum of sums of squares %lf\n", totalSum);

    return 1;
}
