import React, { Component } from 'react';
import {Sensor} from './sensor';
import socket from '../socket';

export class Dashboard extends Component {
    constructor(props) {
        super(props);

        this.state = {
            sensors: props.sensors.slice()
        };
    }

    handleNewSensor(sensor) {
        let sensors = this.state.sensors.slice();
        sensors.push(sensor);

        this.setState({ sensors: sensors });
    }

    componentDidMount() {
        this.channel = socket.socket.channel("dashboard:" + window.initial_state.user_id, {})
        this.channel.on("sensor_new", payload => this.handleNewSensor(payload));

        this.channel.join()
            .receive("ok", resp => { this.setState({ live: true }) })
            .receive("error", resp => { console.log("Unable to join", resp) })
    }


    render() {
        if (!this.state.sensors.length) {
            return (<div> There are not active sensors at the moment </div>)
        }

        const sensors = this.state.sensors.map(sensor => <Sensor key={sensor.id} sensor={sensor} />);
        return (
            <div className="row">
                {sensors}
            </div>
        )
    }
}
