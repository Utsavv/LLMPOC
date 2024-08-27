import torch


def test_pytorch_cuda():
    # Check if PyTorch is installed correctly
    print("PyTorch version:", torch.__version__)

    # Check if CUDA is available
    if torch.cuda.is_available():
        print("CUDA is available!")
        device = torch.device("cuda")
        print(f"Running on the GPU: {torch.cuda.get_device_name(device)}")
    else:
        print("CUDA is not available. Running on the CPU.")
        device = torch.device("cpu")

    # Create two random tensors
    tensor_a = torch.randn(3, 3, device=device)
    tensor_b = torch.randn(3, 3, device=device)

    print("Tensor A:\n", tensor_a)
    print("Tensor B:\n", tensor_b)

    # Perform a matrix multiplication
    tensor_c = torch.matmul(tensor_a, tensor_b)

    print("Result of A * B:\n", tensor_c)


if __name__ == "__main__":
    test_pytorch_cuda()
