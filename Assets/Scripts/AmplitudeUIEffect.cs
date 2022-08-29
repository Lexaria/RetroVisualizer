using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AmplitudeUIEffect : MonoBehaviour
{
    public float startScale, minScale, maxScale;

    public bool useBuffer;

    public RectTransform rectTransform;

    // Start is called before the first frame update
    void Start()
    {
        rectTransform = GetComponent<RectTransform>();
    }

    // Update is called once per frame
    void Update()
    {
        if (useBuffer)
        {
            float newScale = Mathf.Lerp(minScale, maxScale, AudioSourceGetSpectrumData.AmplitudeBuffer);
            rectTransform.localScale = new Vector3(newScale * startScale, newScale * startScale, newScale * startScale);
        }
        else
        {
            float newScale = Mathf.Lerp(minScale, maxScale, AudioSourceGetSpectrumData.Amplitude);
            rectTransform.localScale = new Vector3(newScale * startScale, newScale * startScale, newScale * startScale);
        }
    }
}