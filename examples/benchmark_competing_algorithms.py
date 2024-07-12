import warnings
import os
import scipy.io
import numpy as np
from csi import csi
import concurrent.futures
from sklearn import cluster, datasets, mixture
from sklearn.neighbors import kneighbors_graph
from sklearn.preprocessing import StandardScaler
from pyclustering.cluster.cure import cure;
from pyclustering.cluster.clique import clique
from sklearn.metrics.cluster import normalized_mutual_info_score
import scipy.io
import warnings
warnings.filterwarnings("ignore")
import pandas as pd 
import datetime

numIterations = 26
filename = "./results/" + str(datetime.datetime.now()).replace(":", "-").split(".")[0] + ".xlsx"

# ============
# Load data sets
# ============
directory = os.fsencode("../data/")
datasets = []
dataset_names = []
files = [item for item in os.listdir(directory) if os.path.isfile(os.path.join(directory, item))]

index = 0
for file in files:  
    if os.fsdecode(file).endswith(".mat"):
        datasets.append(scipy.io.loadmat(os.path.join(os.fsdecode(directory), os.fsdecode(file))))
        f = open(os.path.join(os.fsdecode(directory), os.fsdecode(file).split(".")[0], "-label.pa").replace("\\",""), "r")
        labels = f.read()
        datasets[index]["dataset"] = os.fsdecode(file).split("_")[0].split(".")[0]
        datasets[index]["labels"] = list(filter(None, labels.splitlines()))
        dataset_names.append(os.fsdecode(file).split("_")[0].split(".")[0])
        index += 1

# ============
# Set up cluster parameters
# ============

params = {
    'quantile': .05,
    'eps': .05,
    'damping': .95,
    'preference': -200,
    'n_neighbors_ward': 10,
    'n_neighbors_agglomorative': 500,
    'n_clusters': 15,
    'interval': 20,
    'threshold': 10,
}

def process(name, algorithm, dataset):
    with warnings.catch_warnings():
        warnings.filterwarnings(
            "ignore",
            message="the number of connected components of the " +
            "connectivity matrix is [0-9]{1,2}" +
            " > 1. Completing it to avoid stopping the tree early.",
            category=UserWarning)
        warnings.filterwarnings(
            "ignore",
            message="Graph is not fully connected, spectral embedding" +
            " may not work as expected.",
            category=UserWarning)
        if name == "AffinityPropagation" and dataset["dataset"] in ["b1", "b2"]:
           return 100, 0, 0
        if name == "MeanShift" and dataset["dataset"] in ["h32", "h64", "h128", "h256", "h512", "h1024"]:
           return 15, 0, 0
        if name == "Clique" and dataset["dataset"] in ["h32", "h64", "h128", "h256", "h512", "h1024"]:
            return 15, 0, 0
        if name == "Clique":
            clique_instance.process()
        elif name == "Cure":
            cure_instance.process()
        else:
            algorithm.fit(X)

    if name == "Clique":
        clusters = algorithm.get_clusters()
        n_clusters = len(clusters)
        noise = algorithm.get_noise()
        clusters.append(noise)
        y_pred = np.array([(cluster_num, inner_index) for cluster_num, indices in enumerate(clusters) for inner_index in indices])[:, 0]
    elif name == "Cure":
        clusters = algorithm._cure__clusters
        n_clusters = len(clusters)
        y_pred = np.array([(cluster_num, inner_index) for cluster_num, indices in enumerate(clusters) for inner_index in indices])[:, 0]
    else:
        if hasattr(algorithm, 'labels_'):
            y_pred = algorithm.labels_.astype(np.int_)
        else:
            y_pred = algorithm.predict(X)

    if name == "AffinityPropagation" or name == "Ward" or name == "SpectralClustering" or name == "DBSCAN" or name == "AgglomerativeClustering":
        centroids = []
        for p in range(len(set(y_pred))):
            points = X[y_pred==p,:]
            centroids.append(np.mean(points, axis=0))
        algorithm_results = csi(np.array(centroids), GT)
        n_clusters = len(centroids)  
    elif name == "Clique":
        centroids = []
        for p in range(len(set(y_pred))-1):
            points = X[y_pred==p,:]
            centroids.append(np.mean(points, axis=0))
        algorithm_results = csi(np.array(centroids), GT)   
        n_clusters = len(centroids) 
    elif name == "GaussianMixture":
        algorithm_results = csi(algorithm.means_, GT)
        n_clusters = len(algorithm.means_) 
    elif name == "Birch":
        algorithm_results = csi(algorithm.subcluster_centers_, GT)
        n_clusters = len(algorithm.subcluster_centers_)
    elif name == "Cure":
        algorithm_results= csi(np.array(cure_instance._cure__means), GT)
        n_clusters = len(algorithm._cure__means)
    else:
        algorithm_results= csi(algorithm.cluster_centers_, GT)
        n_clusters = len(algorithm.cluster_centers_)

    nmi = normalized_mutual_info_score(y_pred, dataset["labels"])
    return algorithm_results, nmi, n_clusters

algo_names = ["Cure", "Clique", "MiniBatchKMeans", "AffinityPropagation", "MeanShift", "SpectralClustering", "Ward", "AgglomerativeClustering", "DBSCAN", "Birch", "GaussianMixture"]
results_CI = {algorithm: {dataset["dataset"]: [] for dataset in datasets} for algorithm in algo_names}
results_NMI = {algorithm: {dataset["dataset"]: [] for dataset in datasets} for algorithm in algo_names}
results_n_clusters = {algorithm: {dataset["dataset"]: [] for dataset in datasets} for algorithm in algo_names}
for j in range(numIterations):
    np.random.seed(j)
    for i_dataset, dataset in enumerate(datasets):
        # update parameters with dataset-specific values
        X = dataset["data"]
        params.update({'n_clusters': dataset["gt"].shape[0]})

        # normalize dataset for easier parameter selection
        X = StandardScaler().fit_transform(X)
        GT = StandardScaler().fit_transform(dataset["gt"])

        # estimate bandwidth for mean shift
        bandwidth = cluster.estimate_bandwidth(X, quantile=params['quantile'])

        # connectivity matrix for structured Ward
        connectivity = kneighbors_graph(
            X, n_neighbors=params['n_neighbors_ward'], include_self=False)
        
        # make connectivity symmetric
        connectivity_ward = 0.5 * (connectivity + connectivity.T)

        # connectivity matrix for structured Ward
        connectivity = kneighbors_graph(
            X, n_neighbors=params['n_neighbors_agglomorative'], include_self=False)
        
        # make connectivity symmetric
        connectivity_agglomorative = 0.5 * (connectivity + connectivity.T)

        # ============
        # Create cluster objects
        # ============
        cure_instance = cure(X, params['n_clusters'])
        clique_instance = clique(X, params['interval'], params['threshold'])
        two_means = cluster.MiniBatchKMeans(n_clusters=params['n_clusters'], random_state=j)
        affinity_propagation = cluster.AffinityPropagation(damping=params['damping'], preference=params['preference'], random_state=j)
        ms = cluster.MeanShift(bandwidth=bandwidth, bin_seeding=True)
        spectral = cluster.SpectralClustering(
            n_clusters=params['n_clusters'], eigen_solver='arpack',
            affinity="nearest_neighbors", random_state=j) 
        ward = cluster.AgglomerativeClustering(
            n_clusters=params['n_clusters'], linkage='ward',
            connectivity=connectivity_ward)
        average_linkage = cluster.AgglomerativeClustering(
            linkage="average", metric="cityblock",
            n_clusters=params['n_clusters'], connectivity=connectivity_agglomorative)
        dbscan = cluster.DBSCAN(eps=params['eps'])
        birch = cluster.Birch(n_clusters=None)
        gmm = mixture.GaussianMixture(
            n_components=params['n_clusters'], covariance_type='full')

        clustering_algorithms = (
            ('Cure', cure_instance),
            ('Clique', clique_instance),
            ('MiniBatchKMeans', two_means),
            ('AffinityPropagation', affinity_propagation),
            ('MeanShift', ms),
            ('SpectralClustering', spectral),
            ('Ward', ward),
            ('AgglomerativeClustering', average_linkage),
            ('DBSCAN', dbscan),
            ('Birch', birch),
            ('GaussianMixture', gmm),
        )

        with concurrent.futures.ThreadPoolExecutor() as executor:
            
            futures = {executor.submit(process, name, algorithm, dataset): name for name, algorithm in clustering_algorithms}

            for future in concurrent.futures.as_completed(futures):
                name = futures[future]
                try:
                    algorithm_results = future.result()
                    if algorithm_results is not None:
                        results_CI[name][dataset["dataset"]].append(algorithm_results[0])
                        results_NMI[name][dataset["dataset"]].append(algorithm_results[1])
                        results_n_clusters[name][dataset["dataset"]].append(algorithm_results[2])
                        print(f"Finished {j} processing {name} for {dataset['dataset']}")
                except Exception as e:
                    print(f"Error {j} processing {name} for {dataset['dataset']}: {e}")
            
###
# Save to file
###
df = pd.DataFrame()
df.to_excel(filename)
with pd.ExcelWriter(filename, mode='a', engine='openpyxl', if_sheet_exists="replace") as writer:  
    mean_matrix_CI = np.zeros((len(results_CI),len(datasets)))
    std_matrix_CI = np.zeros((len(results_CI),len(datasets)))
    mean_matrix_NMI = np.zeros((len(results_NMI),len(datasets)))
    std_matrix_NMI = np.zeros((len(results_NMI),len(datasets)))
    mean_matrix_n_clusters = np.zeros((len(results_n_clusters),len(datasets)))
    std_matrix_n_clusters = np.zeros((len(results_n_clusters),len(datasets)))

    for i, algorithm in enumerate(results_CI):
        for j, dataset in enumerate(results_CI[algorithm]):
            mean_matrix_CI[i, j] = np.mean(results_CI[algorithm][dataset])
            std_matrix_CI[i, j] = np.std(results_CI[algorithm][dataset])
            mean_matrix_NMI[i, j] = np.mean(results_NMI[algorithm][dataset])
            std_matrix_NMI[i, j] = np.std(results_NMI[algorithm][dataset])
            mean_matrix_n_clusters[i, j] = np.mean(results_n_clusters[algorithm][dataset])
            std_matrix_n_clusters[i, j] = np.std(results_n_clusters[algorithm][dataset])
        df = pd.DataFrame(results_CI[algorithm])
        df.to_excel(writer, sheet_name=algorithm + "_CI")
        df = pd.DataFrame(results_NMI[algorithm])
        df.to_excel(writer, sheet_name=algorithm + "_NMI")
        df = pd.DataFrame(results_n_clusters[algorithm])
        df.to_excel(writer, sheet_name=algorithm + "_n_clusters")


    df = pd.DataFrame(mean_matrix_CI, columns = dataset_names, index = algo_names)
    df.to_excel(writer, sheet_name="mean_ci")
    df = pd.DataFrame(std_matrix_CI, columns = dataset_names, index = algo_names)
    df.to_excel(writer, sheet_name="std_ci")
    df = pd.DataFrame(mean_matrix_NMI, columns = dataset_names, index = algo_names)
    df.to_excel(writer, sheet_name="mean_nmi")
    df = pd.DataFrame(std_matrix_NMI, columns = dataset_names, index = algo_names)
    df.to_excel(writer, sheet_name="std_nmi")
    df = pd.DataFrame(mean_matrix_n_clusters, columns = dataset_names, index = algo_names)
    df.to_excel(writer, sheet_name="mean_n_clusters")
    df = pd.DataFrame(std_matrix_n_clusters, columns = dataset_names, index = algo_names)
    df.to_excel(writer, sheet_name="std_n_clusters")
