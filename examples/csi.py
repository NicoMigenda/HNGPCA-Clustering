import numpy as np

def csi(cluster_centers, gt):
    distances = np.linalg.norm(cluster_centers[:, np.newaxis, :] - gt, axis=2)
    closest_ground_truth_indices = np.argmin(distances, axis=1)
    CI_1 = len(cluster_centers) - len(set(closest_ground_truth_indices))

    # Calculate distances between each ground truth cluster and all cluster centers
    distances_gt = np.linalg.norm(gt[:, np.newaxis, :] - cluster_centers, axis=2)
    closest_cluster_indices = np.argmin(distances_gt, axis=1)
    CI_2 = len(gt) - len(set(closest_cluster_indices))
    
    return np.maximum(CI_1, CI_2)
