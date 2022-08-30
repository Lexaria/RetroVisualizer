using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MusicStatusUI : MonoBehaviour
{
    private Text _text;
    private bool isPlay;
    // Start is called before the first frame update
    void Start()
    {
        _text = GetComponent<Text>();
    }

    // Update is called once per frame
    void Update()
    {
        isPlay = MusicPlayer.isPlay;
        if (isPlay)
        {
            _text.text =  "\u25B6 " + "Play"  + "\n" + "tofubeats" + " - " + "Suisei";
        }
        else
        {
            _text.text = "Pause";
        }
    }
}
