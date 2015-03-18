/** @jsx React.DOM */

// Constants
var Events = require('../Events');
var Helpers = require('../Helpers');
var debug = Helpers.debug;
var t = Helpers.translate;

// Global variables
var store = require('../store');
var flux = require('../flux/dispatcher');

// Props: account: Account
var AccountListItem = React.createClass({

    _onClick: function() {
        flux.dispatch({
            type: Events.user.selected_account,
            accountId: this.props.account.id
        });
    },

    render: function() {
        return (
            <li className="active">
                <span>
                    <a href="#" onClick={this._onClick}>{this.props.account.title}</a>
                </span>
            </li>
        );
    }
});

// State: accounts: [{id: accountId, title: accountTitle}]
var AccountListComponent = module.exports = React.createClass({

    getInitialState: function() {
        return {
            accounts: []
        };
    },

    _listener: function() {
        this.setState({
            accounts: store.getCurrentBankAccounts()
        });
    },

    componentDidMount: function() {
        store.on(Events.state.accounts, this._listener);
    },

    componentWillUnmount: function() {
        store.removeListener(Events.state.accounts, this._listener);
    },

    render: function() {
        var accounts = this.state.accounts.map(function (a) {
            return (
                <AccountListItem key={a.id} account={a} />
            );
        });

        return (
            <div className="sidebar-list">
                <ul className="sidebar-sublist"><span className="topic">{t('Accounts')}</span>
                    {accounts}
                </ul>
            </div>
        );
    }
});

