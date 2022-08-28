using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Instanciate : MonoBehaviour
{
    public GameObject sampleCubePrefab;

    private GameObject[] sampleCubeArray = new GameObject[512];

    public float maxScale;
    // Start is called before the first frame update
    void Start()
    {
        for (int i = 0; i < 512; i++)
        {
            GameObject instanceSampleCube = (GameObject)Instantiate(sampleCubePrefab);
            instanceSampleCube.transform.position = this.transform.position;
            instanceSampleCube.transform.parent = this.transform;
            instanceSampleCube.name = "SampleCube" + i;
            this.transform.eulerAngles = new Vector3(0, -360.0f / 512 * i, 0);
            instanceSampleCube.transform.position = Vector3.forward * 100;
            sampleCubeArray[i] = instanceSampleCube;
        }
    }

    // Update is called once per frame
    void Update()
    {
        for (int i = 0; i < 512; i++)
        {
            if (sampleCubeArray != null)
            {
                sampleCubeArray[i].transform.localScale =
                    new Vector3(10, 10, (AudioSourceGetSpectrumData.spectrum[i] * maxScale) + 2);
            }
        }
    }
}
