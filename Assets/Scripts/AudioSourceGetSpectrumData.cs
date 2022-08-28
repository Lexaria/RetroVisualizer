using System;
using Unity.VisualScripting;
using UnityEngine;


[RequireComponent(typeof(AudioSource))]
public class AudioSourceGetSpectrumData : MonoBehaviour
{
    public static float[] spectrum = new float[512];

    public static float[] freqBand = new float[8];

    public static float[] bandBuffer = new float[8];

    private float[] bufferDecrease = new float[8];

    private float[] freqBandHighest = new float[8];

    public static float[] audioBand = new float[8];
    public static float[] audioBandBuffer = new float[8];

    // public Material material;
    private void Start()
    {
        // if (material == null)
        // {
        //     Debug.Log("Null Material");
        // }
    }

    void Update()
    {

        AudioListener.GetSpectrumData(spectrum, 0, FFTWindow.Blackman);
        MakeFrequencyBands();
        BandBuffer();
        CreateAudioBands();
        // material.SetFloatArray("_Spectrum", spectrum);
    }

    void MakeFrequencyBands()
    {
        // 0 - 22050 Hz
        // 43 Hz per Sample
        // - Sub Bass: 20-60 Hz
        // - Bass: 60- 250 Hz
        // - Low Midrange: 250-500 Hz
        // - Midrange: 500-2k Hz
        // - Upper Midrange: 2k-4k Hz
        // - Presence: 4k-6k Hz
        // - Brilliance: 6k-20k Hz
        
        // - 0 - 2 = 43 Hz
        // - 1 - 4 = 172 Hz (87 - 258)
        // - 2 - 8 = 344 Hz (259 - 602)
        // - 3 - 16 = 688 (603 - 1290)
        // - 4 - 32 = 1376 (1291 - 2666)
        // - 5 - 64 = 2752 (2667 - 5418)
        // - 6 - 128 = 5504 (5419 - 10922)
        // - 7 - 256 = 11008 (10923 - 21930)
        // 510
        int count = 0;
        for (int i = 0; i < 8; i++)
        {
            float average = 0;
            int sampleCount = (int)Mathf.Pow(2, i) * 2;
            if (i == 7)
            {
                sampleCount += 2;
            }

            for (int j = 0; j < sampleCount; j++)
            {
                average += spectrum[count] * (count + 1);
                count++;
            }

            average /= count;
            freqBand[i] = average * 10;
        }
    }

    void BandBuffer()
    {
        for (int g = 0; g < 8; g++)
        {
            if (freqBand[g] > bandBuffer[g])
            {
                bandBuffer[g] = freqBand[g];
                bufferDecrease[g] = 0.005f;
            }
            if (freqBand[g] < bandBuffer[g])
            {
                bandBuffer[g] -= bufferDecrease[g];
                bufferDecrease[g] *= 1.2f;
            }
        }
    }

    void CreateAudioBands()
    {
        for (int i = 0; i < 8; i++)
        {
            if (freqBand[i] > freqBandHighest[i])
            {
                freqBandHighest[i] = freqBand[i];
            }

            audioBand[i] = (freqBand[i] / freqBandHighest[i]);
            audioBandBuffer[i] = (bandBuffer[i] / freqBandHighest[i]);
        }
    }

    void GetAmplitube()
    {
        
    }
}