import React, { Component } from "react";
import socket from "../socket";

export class Sensor extends Component {
    constructor(props)  {
        super(props);

        let last_reading = null;
        if (props.readings && props.readings.length) {
            last_reading = props.readings[0];
        }

        this.state = {
            live: false,
            sensor: {
                name: props.sensor.name || props.sensor.sensor_uid,
                lower: props.sensor.lower,
                upper: props.sensor.upper,
                relay_status: props.sensor.relay_status,
                op_mode: props.sensor.op_mode
            },
            last_reading: last_reading
        }
    }

    handleUpdateSensorInfo(sensor_info) {
        this.setState({ sensor: {
            name: sensor_info.name || sensor_info.sensor_uid,
            lower: sensor_info.lower,
            upper: sensor_info.upper,
            relay_status: sensor_info.relay_status,
            op_mode: sensor_info.op_mode
        }});
    }

    handleNewReading(reading) {
        if (reading.type === "temperature") {
            this.setState({last_reading: reading});
        } 
    }
    
    componentDidMount() {
        this.channel = socket.socket.channel("sensor:" + this.props.sensor.id, {})
        this.channel.on("sensor_update", payload => this.handleUpdateSensorInfo(payload));
        this.channel.on("sensor_reading", payload => this.handleNewReading(payload));

        this.channel.join()
            .receive("ok", resp => { this.setState({live: true}) })
            .receive("error", resp => { console.log("Unable to join", resp) })
    }

    componentWillUnmount() {
        this.channel.leave();
    }

    render() {
        let status_class = ["col-md-2", "sensor"];
        let last_reading_value = '--'

        if (this.state.last_reading) {
            last_reading_value = this.state.last_reading.value;
            if (+this.state.last_reading.value >= this.state.sensor.upper) {
                status_class.push("above");
            }
            if (+this.state.last_reading.value <= this.state.sensor.lower) {
                status_class.push("bellow");
            }
        }

        if (this.state.sensor.op_mode === 'O') {
            status_class.push("override");
        }

        return (
            <div className={status_class.join(" ")}>
                <span className="title">
                    {this.state.sensor.name}

                    <span className="fa fa-question-circle pull-right"></span>
                </span>
                <hr />

                {this.state.sensor.relay_status ? <span className='status fa fa-lightbulb-o'></span> : <span className='status'>--</span>}
                <span className="value pull-right"> {last_reading_value} </span>
            </div>
        )
    }
}


