#Student Name: Harun Reşid Ergen
#Student Number: 2019400141
#Compile Status: Compiling
#Program Status: Working
#Notes: Python 3.10.6 is used. Some Turkish characters are replaced with their corresponding ascii characters (ğ -> g) due to an encoding error we encountered in our testing environment.

from mpi4py import MPI
import sys

comm = MPI.COMM_WORLD
world_size = comm.Get_size()
rank = comm.Get_rank()

worker_num = world_size-1

# P(karar verecek) = P(karar) * P(verecek|karar)
# P(verecek|karar) = Freq(karar verecek) / Freq(karar)   - conditional probability of bigram

# Parses arguments given through console
def parse_args():
    args = sys.argv
    input_file = args[args.index("--input_file")+1]
    merge_method = args[args.index("--merge_method")+1]
    test_file = args[args.index("--test_file")+1]
    return [input_file, merge_method, test_file]
    

# Calculates frequencies of bigram and bigram[0] on sentence
def get_freq(bigram, sentence):
    unicount = 0
    bicount = 0
    for i in range(len(sentence)-1):
        if bigram[0] == sentence[i]:    # first word is found
            unicount += 1
            if bigram[1] == sentence[i+1]:  # second word is also found
                bicount += 1
    if bigram[0] == sentence[-1]:   # check if the last word of the sentence is the first word of the bigram
        unicount += 1
    return unicount, bicount

# Merges two lists
def merge_freqs(source1, source2):
    for i in range(len(source1)):
        source2[i] += source1[i]
    return source2

def main(args):
    bigrams = []
    f = open(args[2], "r", encoding="utf-8") # read bigrams from the test file
    for line in f:
        bigrams.append(tuple(line.strip("\n").split(" "))) # split by whitespace
    f.close()

    # Initialise frequency tables for workers and the master
    bigram_freqs = [0 for bigram in bigrams]
    unigram_freqs = [0 for bigram in bigrams]

    if rank == 0: # master
        lines = []
        f = open(args[0], "r", encoding="utf-8") # open the input file and read lines
        for line in f:
            lines.append(line.strip("\n"))
        f.close()

        # Take a partition of input lines
        line_num = len(lines)
        start_indices = [0 for i in range(worker_num)]
        counts = [0 for i in range(worker_num)]

        for i in range(worker_num):
            start_indices[i] = (i*line_num)//worker_num
            counts[i] = ((i+1)*line_num)//worker_num - (i*line_num)//worker_num

        for i in range(worker_num): # a worker gets lines[start:end]
            start = start_indices[i]
            end = start_indices[i] + counts[i]
            comm.send(lines[start:end], dest=i+1)
            
        if args[1] == "MASTER":
            for i in range(worker_num): # wait for workers
                freqs = comm.recv(source=i+1) # freqs = [unigram_freqs, bigram_freqs]
                unigram_freqs = merge_freqs(unigram_freqs, freqs[0])
                bigram_freqs = merge_freqs(bigram_freqs, freqs[1])
        elif args[1] == "WORKERS":
            freqs = comm.recv(source=worker_num) # wait for the last worker
            unigram_freqs = merge_freqs(unigram_freqs, freqs[0])
            bigram_freqs = merge_freqs(bigram_freqs, freqs[1])

        # Calculate conditional probabilities
        for index, bigram in enumerate(bigrams):
            try:
                cond_prob = bigram_freqs[index]/unigram_freqs[index]
            except:
                cond_prob = 0.0
            try:
                print("The conditional probability of bigram " + " ".join(bigram), "is", cond_prob)
            except:
                # UnicodeError exception handling
                print("The conditional probability of bigram", tr_to_en(" ".join(bigram)), "is", cond_prob)

    else: # workers
        data = comm.recv(source=0) # wait master to send data
        print("The worker having rank {} received {} sentences".format(rank, len(data)))
        for index in range(len(data)):  # split sentences by whitespace
            data[index] = data[index].split(" ")
        
        # Calculate frequencies for each sentence and bigram
        for sentence in data:
            for index, bigram in enumerate(bigrams):
                unicount, bicount = get_freq(bigram, sentence)
                unigram_freqs[index] += unicount
                bigram_freqs[index] += bicount
        
        if args[1] == "MASTER":
            comm.send([unigram_freqs, bigram_freqs], dest=0)            # send freqs to master
        elif args[1] == "WORKERS":
            if rank != 1:
                freqs = comm.recv(source=rank-1)                         # wait for the previous worker. worker 1 doesnt wait anyone
                unigram_freqs = merge_freqs(unigram_freqs, freqs[0])
                bigram_freqs = merge_freqs(bigram_freqs, freqs[1])
            if rank < world_size-1:
                comm.send([unigram_freqs, bigram_freqs], dest=rank+1)    # send freqs to the next worker
            else:
                comm.send([unigram_freqs, bigram_freqs], dest=0)         # the last worker sends freqs to the master

def tr_to_en(text):
    tr = "İıĞğÜüŞşÖöÇç"
    en = "IiGgUuSsOoCc"
    for x,y in zip(list(tr),list(en)):
        text = text.replace(x,y)
    return text

if __name__ == "__main__":
    args = parse_args()
    main(args)


