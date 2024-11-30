// docker run -it -v /Users/mariacolta/Code/uni-labs/so-labs/lab4/producer-consumer:/app --name producer_consumer_env ubuntu
// apt update
// apt install -y build-essential manpages-dev gdb nano

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define BUFFER_SIZE 10 // Configurable buffer size

int buffer[BUFFER_SIZE];
int count = 0; // Number of items in the buffer

// Buffer indices
int in = 0;  // Index for the next producer item
int out = 0; // Index for the next consumer item

// Synchronization primitives
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t buffer_not_full = PTHREAD_COND_INITIALIZER;
pthread_cond_t buffer_not_empty = PTHREAD_COND_INITIALIZER;

// Number of producers and consumers (configurable)
#define NUM_PRODUCERS 3
#define NUM_CONSUMERS 2

void* producer(void* arg) {
    int producer_id = *((int*)arg);
    while (1) {
        // Produce an item (here, just an integer)
        int item = rand() % 100;

        // Acquire the mutex lock
        pthread_mutex_lock(&mutex);

        // Wait if buffer is full
        while (count == BUFFER_SIZE) {
            // Buffer is full; wait for a consumer to consume
            pthread_cond_wait(&buffer_not_full, &mutex);
        }

        // Add the item to the buffer
        buffer[in] = item;
        in = (in + 1) % BUFFER_SIZE;
        count++;

        printf("Producer %d produced item %d\n", producer_id, item);

        // Signal that the buffer is not empty
        pthread_cond_signal(&buffer_not_empty);

        // Release the mutex lock
        pthread_mutex_unlock(&mutex);

        sleep(1); // Simulate time taken to produce an item
    }
    return NULL;
}

void* consumer(void* arg) {
    int consumer_id = *((int*)arg);
    while (1) {
        // Acquire the mutex lock
        pthread_mutex_lock(&mutex);

        // Wait if buffer is empty
        while (count == 0) {
            // Buffer is empty; wait for a producer to produce
            pthread_cond_wait(&buffer_not_empty, &mutex);
        }

        // Remove the item from the buffer
        int item = buffer[out];
        out = (out + 1) % BUFFER_SIZE;
        count--;

        printf("Consumer %d consumed item %d\n", consumer_id, item);

        // Signal that the buffer is not full
        pthread_cond_signal(&buffer_not_full);

        // Release the mutex lock
        pthread_mutex_unlock(&mutex);

        sleep(1); // Simulate time taken to consume an item
    }
    return NULL;
}

int main(int argc, char* argv[]) {
    // Optional: Get the number of producers and consumers from command-line arguments
    int num_producers = NUM_PRODUCERS;
    int num_consumers = NUM_CONSUMERS;

    if (argc == 3) {
        num_producers = atoi(argv[1]);
        num_consumers = atoi(argv[2]);
    }

    pthread_t producers[num_producers], consumers[num_consumers];
    int producer_ids[num_producers], consumer_ids[num_consumers];

    // Initialize mutex and condition variables
    pthread_mutex_init(&mutex, NULL);
    pthread_cond_init(&buffer_not_full, NULL);
    pthread_cond_init(&buffer_not_empty, NULL);

    // Create producer threads
    for (int i = 0; i < num_producers; i++) {
        producer_ids[i] = i + 1;
        if (pthread_create(&producers[i], NULL, producer, &producer_ids[i]) != 0) {
            perror("Failed to create producer thread");
            exit(EXIT_FAILURE);
        }
    }

    // Create consumer threads
    for (int i = 0; i < num_consumers; i++) {
        consumer_ids[i] = i + 1;
        if (pthread_create(&consumers[i], NULL, consumer, &consumer_ids[i]) != 0) {
            perror("Failed to create consumer thread");
            exit(EXIT_FAILURE);
        }
    }

    // Join threads (not strictly necessary since threads run infinite loops)
    for (int i = 0; i < num_producers; i++) pthread_join(producers[i], NULL);
    for (int i = 0; i < num_consumers; i++) pthread_join(consumers[i], NULL);

    // Clean up
    pthread_mutex_destroy(&mutex);
    pthread_cond_destroy(&buffer_not_full);
    pthread_cond_destroy(&buffer_not_empty);

    return 0;
}
