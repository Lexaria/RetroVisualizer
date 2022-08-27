using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.PlayerLoop;

public class MusicPlayer : MonoBehaviour
{
    public AudioSource audioSource;
    private bool isPlay;

    // Start is called before the first frame update
    void Start()
    {
        audioSource = GetComponent<AudioSource>();
        audioSource.volume = 1;
        audioSource.loop = true;
        audioSource.playOnAwake = true;
        isPlay = true;
    }


    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(1))
        {
            Debug.Log("Replay");
            audioSource.Play();
            isPlay = true;
        }

        if (Input.GetMouseButtonDown(0))
        {
            if (isPlay == true)
            {
                Debug.Log("Stop");
                audioSource.Pause();
                isPlay = false;
            }
            else
            {
                Debug.Log("Continue");
                audioSource.UnPause();
                isPlay = true;
            }
        }
    }
}