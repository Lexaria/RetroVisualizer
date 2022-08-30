using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ShowTime : MonoBehaviour
{
    private DateTime _dateTime;

    private Text _text;
    // Start is called before the first frame update
    void Start()
    {
        _dateTime = new DateTime();
        _text = GetComponent<Text>();
    }

    // Update is called once per frame
    void Update()
    {
        _dateTime = DateTime.Now;
        _text.text = _dateTime.ToString("hh:mm:ss tt");
    }
}
