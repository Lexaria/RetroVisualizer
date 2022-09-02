using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateLight : MonoBehaviour
{
    public float rotateSpeed = 10.0f;

    private float x = 0;

    private float y = 0;

    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        x += Time.deltaTime * rotateSpeed + Random.Range(0, 1);
        y += Time.deltaTime * rotateSpeed + Random.Range(0, 1);
        transform.rotation = Quaternion.Euler(x, y, 0);
    }
}