/*
 * Create a WAV file of 440Hz sin wave. (Public Domain)
 *
 * gcc -Wall -O make_440Hz.c -o make_440Hz
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include <string.h>

const uint32_t SampleRate = 48000;

const double Frequency = 440.0;
const double Volume    = 8192.0 * 2;
const uint32_t Span    = 15;

typedef struct {
    char     header[4];
    uint32_t fileLength;
    char     fmtHead[4];
} FileHeader;

typedef struct {
    char     chunkID[4];
    uint32_t chunkSize;
    uint16_t formatCode;
    uint16_t channels;
    uint32_t sampleRatio;
    uint32_t sampleBytePerSeccond;
    uint16_t alignment;
    uint16_t bitDepth;
} FormatChunk;

typedef struct {
    char    chunkID[4];
    int32_t chunkSize;
} DataChunk;

int main( int argc, char *argv[] )
{
    int return_status = -1;

    FileHeader file_header;
    FormatChunk format_chunk;
    DataChunk data_chunk;

    FILE *fp = NULL;
    int16_t *sample_buf = NULL;
    uint32_t i;

    file_header.fileLength = (sizeof(FileHeader) + sizeof(FormatChunk) +
			      sizeof(DataChunk) +
			      sizeof(int16_t) * SampleRate * Span) - 8;

    memcpy(file_header.header, "RIFF", 4);
    memcpy(file_header.fmtHead, "WAVE", 4);

    memcpy(format_chunk.chunkID, "fmt ", 4);
    format_chunk.chunkSize   = 16;
    format_chunk.formatCode  = 1;
    format_chunk.channels    = 1;
    format_chunk.sampleRatio = SampleRate;
    format_chunk.sampleBytePerSeccond = SampleRate * 2;
    format_chunk.alignment = 2;
    format_chunk.bitDepth = 16;

    if ( argc < 2 ) {
        printf("[USAGE]\n");
	printf("%s output.wav\n", argv[0]);
	goto quit;
    }

    sample_buf = (int16_t *)malloc(sizeof(int16_t) * SampleRate * Span);
    if ( sample_buf == NULL ) {
        fprintf(stderr,"[ERROR] malloc() failed\n");
	goto quit;
    }

    fp = fopen(argv[1], "wb");
    if ( fp == NULL ) {
        fprintf(stderr,"[ERROR] Cannot open file: %s\n", argv[1]);
        goto quit;
    }

    memcpy(data_chunk.chunkID, "data", 4);
    data_chunk.chunkSize =  sizeof(int16_t) * SampleRate * Span;
    for( i=0 ; i < SampleRate * Span ; i++ ) {
	double th = 2.0 * M_PI * (double)i * ( Frequency / (double)SampleRate ) ;
        sample_buf[i] = (int16_t)( round(Volume * sin(th)) );
    }
    fwrite(&file_header, 1, sizeof(FileHeader), fp);
    fwrite(&format_chunk, 1, sizeof(FormatChunk), fp);
    fwrite(&data_chunk, 1, sizeof(DataChunk), fp);
    fwrite(sample_buf, 1, sizeof(int16_t) * SampleRate * Span, fp);

    return_status = 0;

 quit:
    if ( fp != NULL ) fclose(fp);
    if ( sample_buf != NULL ) free(sample_buf);

    return return_status;

}
