using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AmplitudeMaterialEffect : MonoBehaviour
{
    public float minEmission, maxEmission;

    public bool useBuffer;

    public Material material;
    public Color EmissionColor;

    // Start is called before the first frame update
    void Start()
    {
        material = GetComponent<MeshRenderer>().materials[0];
        EmissionColor = material.GetColor("_EmissionColor");
    }

    // Update is called once per frame
    void Update()
    {
        if (useBuffer)
        {
            float newAmplitude = Mathf.Lerp(minEmission, maxEmission, AudioSourceGetSpectrumData.AmplitudeBuffer);
            Color color = EmissionColor * newAmplitude;
            material.SetColor("_EmissionColor", color);
        }
        else
        {
            float newAmplitude = Mathf.Lerp(minEmission, maxEmission, AudioSourceGetSpectrumData.Amplitude);
            Color color = EmissionColor * newAmplitude;
            material.SetColor("_EmissionColor", color);
        }
    }
}