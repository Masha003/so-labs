// docker run -it -v /Users/mariacolta/Code/uni-labs/so-labs/lab4/reader-writer:/app --name reader_writer_env ubuntu

#include <pthread.h>
#include <semaphore.h>
#include <stdio.h>
#include <unistd.h>

sem_t resource_access;
sem_t read_count_access;
int read_count = 0;

void* reader(void* id) {
    int reader_id = *((int*)id);
    while (1) {
        sem_wait(&read_count_access);
        read_count++;
        if (read_count == 1) sem_wait(&resource_access); // First reader locks resource
        sem_post(&read_count_access);

        printf("Reader %d: Reading...\n", reader_id);
        sleep(1);

        sem_wait(&read_count_access);
        read_count--;
        if (read_count == 0) sem_post(&resource_access); // Last reader unlocks resource
        sem_post(&read_count_access);

        sleep(1);
    }
    return NULL;
}

void* writer(void* id) {
    int writer_id = *((int*)id);
    while (1) {
        sem_wait(&resource_access); // Writer locks resource

        printf("Writer %d: Writing...\n", writer_id);
        sleep(2);

        sem_post(&resource_access); // Writer unlocks resource
        sleep(1);
    }
    return NULL;
}

int main() {
    pthread_t readers[5], writers[2];
    int reader_ids[5], writer_ids[2];

    sem_init(&resource_access, 0, 1);
    sem_init(&read_count_access, 0, 1);

    // Create reader threads
    for (int i = 0; i < 5; i++) {
        reader_ids[i] = i + 1;
        pthread_create(&readers[i], NULL, reader, &reader_ids[i]);
    }

    // Create writer threads
    for (int i = 0; i < 2; i++) {
        writer_ids[i] = i + 1;
        pthread_create(&writers[i], NULL, writer, &writer_ids[i]);
    }

    // Join threads (not strictly necessary for infinite loop)
    for (int i = 0; i < 5; i++) pthread_join(readers[i], NULL);
    for (int i = 0; i < 2; i++) pthread_join(writers[i], NULL);

    sem_destroy(&resource_access);
    sem_destroy(&read_count_access);

    return 0;
}
