// docker run -it -v /Users/mariacolta/Code/uni-labs/so-labs/lab4/reader-writer:/app --name reader_writer_env ubuntu
// apt update
// apt install -y build-essential manpages-dev gdb nano

#include <pthread.h>
#include <semaphore.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

// Semaphores and shared variables
sem_t resource_access;
sem_t read_count_access;
int read_count = 0;

// Shared resource (file)
FILE* shared_file;
pthread_mutex_t file_mutex = PTHREAD_MUTEX_INITIALIZER;

// Function prototypes
void* reader(void* id);
void* writer(void* id);

// Number of readers and writers (configurable)
#define NUM_READERS 5
#define NUM_WRITERS 2

int main(int argc, char* argv[]) {
    // Optional: Get number of readers and writers from command-line arguments
    int num_readers = NUM_READERS;
    int num_writers = NUM_WRITERS;

    if (argc == 3) {
        num_readers = atoi(argv[1]);
        num_writers = atoi(argv[2]);
    }

    pthread_t readers[num_readers], writers[num_writers];
    int reader_ids[num_readers], writer_ids[num_writers];

    // Initialize semaphores
    sem_init(&resource_access, 0, 1);
    sem_init(&read_count_access, 0, 1);

    // Open the shared file
    shared_file = fopen("shared_resource.txt", "w+");
    if (shared_file == NULL) {
        perror("Failed to open shared resource file");
        exit(EXIT_FAILURE);
    }

    // Initialize the file with some content
    fprintf(shared_file, "Initial file content.\n");
    fflush(shared_file);

    // Create reader threads
    for (int i = 0; i < num_readers; i++) {
        reader_ids[i] = i + 1;
        if (pthread_create(&readers[i], NULL, reader, &reader_ids[i]) != 0) {
            perror("Failed to create reader thread");
            exit(EXIT_FAILURE);
        }
    }

    // Create writer threads
    for (int i = 0; i < num_writers; i++) {
        writer_ids[i] = i + 1;
        if (pthread_create(&writers[i], NULL, writer, &writer_ids[i]) != 0) {
            perror("Failed to create writer thread");
            exit(EXIT_FAILURE);
        }
    }

    // Join threads (not strictly necessary since threads run infinite loops)
    for (int i = 0; i < num_readers; i++) pthread_join(readers[i], NULL);
    for (int i = 0; i < num_writers; i++) pthread_join(writers[i], NULL);

    // Clean up
    sem_destroy(&resource_access);
    sem_destroy(&read_count_access);
    pthread_mutex_destroy(&file_mutex);
    fclose(shared_file);

    return 0;
}

void* reader(void* arg) {
    int reader_id = *((int*)arg);
    char buffer[256];

    while (1) {
        // Entry section
        sem_wait(&read_count_access);
        read_count++;
        if (read_count == 1) {
            sem_wait(&resource_access); // First reader locks resource
        }
        sem_post(&read_count_access);

        // Critical section: Read from the shared file
        pthread_mutex_lock(&file_mutex); // Protect file operations
        fseek(shared_file, 0, SEEK_SET);
        if (fgets(buffer, sizeof(buffer), shared_file) != NULL) {
            printf("Reader %d: Read content: %s", reader_id, buffer);
        } else {
            printf("Reader %d: Failed to read content.\n", reader_id);
        }
        pthread_mutex_unlock(&file_mutex);

        // Exit section
        sem_wait(&read_count_access);
        read_count--;
        if (read_count == 0) {
            sem_post(&resource_access); // Last reader unlocks resource
        }
        sem_post(&read_count_access);

        sleep(1); // Simulate time between reads
    }
    return NULL;
}

void* writer(void* arg) {
    int writer_id = *((int*)arg);
    char write_buffer[256];

    while (1) {
        // Entry section
        sem_wait(&resource_access); // Writer locks resource

        // Critical section: Write to the shared file
        pthread_mutex_lock(&file_mutex); // Protect file operations
        snprintf(write_buffer, sizeof(write_buffer), "Writer %d was here.\n", writer_id);
        fseek(shared_file, 0, SEEK_SET);
        ftruncate(fileno(shared_file), 0); // Clear the file before writing
        fprintf(shared_file, "%s", write_buffer);
        fflush(shared_file);
        printf("Writer %d: Wrote content: %s", writer_id, write_buffer);
        pthread_mutex_unlock(&file_mutex);

        // Exit section
        sem_post(&resource_access); // Writer unlocks resource

        sleep(2); // Simulate time between writes
    }
    return NULL;
}
