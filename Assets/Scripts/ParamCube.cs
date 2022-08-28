using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParamCube : MonoBehaviour
{
    public int band;

    public float startScale, scaleMultiplier;

    public bool useBuffer;

    private Material _material;

    // Start is called before the first frame update
    void Start()
    {
        _material = GetComponent<MeshRenderer>().materials[0];
    }

    // Update is called once per frame
    void Update()
    {
        if (useBuffer)
        {
            transform.localScale = new Vector3(transform.localScale.x, transform.localScale.y,
                (AudioSourceGetSpectrumData.bandBuffer[band] * scaleMultiplier) + startScale);
            Color color = new Color(AudioSourceGetSpectrumData.audioBandBuffer[band],
                AudioSourceGetSpectrumData.audioBandBuffer[band], AudioSourceGetSpectrumData.audioBandBuffer[band]);
            _material.SetColor("_EmissionColor", color);
        }
        else
        {
            transform.localScale = new Vector3(transform.localScale.x, transform.localScale.y,
                (AudioSourceGetSpectrumData.freqBand[band] * scaleMultiplier) + startScale);
            Color color = new Color(AudioSourceGetSpectrumData.audioBand[band],
                AudioSourceGetSpectrumData.audioBand[band], AudioSourceGetSpectrumData.audioBand[band]);
            _material.SetColor("_EmissionColor", color);
        }
    }
}