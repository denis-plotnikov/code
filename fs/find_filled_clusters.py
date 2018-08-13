#!/usr/bin/python3.4
# finds the non-empty blocks in qcow2 file
# starting from the certain offset

import sys
from threading import Lock
from concurrent.futures import ThreadPoolExecutor, as_completed

CLUSTER_SIZE = 65536

def init():
    global cluster
    cluster = int(sys.argv[2])

    global lock
    lock = Lock()

    global file_name
    file_name = sys.argv[1]

def get_cluster():
    global lock
    lock.acquire()

    global cluster
    result = cluster
    cluster += CLUSTER_SIZE

    lock.release()
    return result

def func():
    with open(file_name, 'rb') as f:
        while True: 
            cluster = get_cluster()
            f.seek(cluster)
            data = f.read(CLUSTER_SIZE)
            if not data:
                break
            if sum(data) > 0:
                offset = 0
                # looking for non-empty qword
                for qw_n in range(int(len(data)/8)):
                    qw = data[8*qw_n : 8*(qw_n+1)]
                    if sum(qw) > 0:
                        offset = qw_n * 8 
                        break
                print("cluster: {0:#04x} offset: {1:#04x} val:{2}".
                       format(cluster, cluster + offset, "".join("%02x" % b for b in qw)))

def main():
    init()
    global cluster
    if cluster & (CLUSTER_SIZE-1):
       print("Offset should be cluster_size({0}) aligned".format(CLUSTER_SIZE))
       sys.exit(22)


    workers_num = 8
    executor = ThreadPoolExecutor(max_workers=workers_num)

    workers = [executor.submit(func) for i in range(workers_num)]
    for completion in as_completed(workers):
        foo = completion.result()

    print("Done!")

main()
