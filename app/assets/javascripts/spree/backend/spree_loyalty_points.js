function SelectOptionChange(selectBoxId, containerId, heading) {
    var that = this;
    this.selectBoxId = selectBoxId;
    this.containerId = containerId;
    $('#' + this.selectBoxId).on('change', function(event) {
        var appendPath = event.target.value;
        $.ajax({
            url: $(this).attr('data-transactions-link') + "/order_transactions/" + appendPath,
            dataType: "json",
            success: function(responseData, returnStatus, xhr) {
                var $mainContainer = $('#' + containerId);
                // Remove table for last order transactions
                $mainContainer.html("");
                // Add heading
                $mainContainer.append($('<h5>' + heading + '</h5>'));
                // Parse response data from ajax
                that.displayData(responseData, $mainContainer);
            }
        });
    });
}
$(document).ready(function() {
    var orderSelection = new SelectOptionChange('loyalty_points_transaction_source_id', 'loyalty-points-order-transactions', 'Loyalty Point Transactions')
    orderSelection.displayData = function(responseData, container) {
        var $table = this.appendTable(container);
        this.appendHeaderRow($table);
        var $tableBody = this.appendTableBody($table);

        $.each(responseData, function(index, transaction) {
            var $transactionRow = this.appendTableRow($tableBody);
            transaction_date = new Date(transaction['updated_at']).toLocaleString();
            this.appendTableRowData(transaction_date, $transactionRow);
            this.appendSourceReference(transaction['source_type'], transaction['source']['number'], $transactionRow);
            this.appendTableRowData(transaction['comment'], $transactionRow);
            this.appendTableRowData(transaction['transaction_type'], $transactionRow);
            this.appendTableRowData(transaction['loyalty_points'], $transactionRow);
            this.appendTableRowData(transaction['balance'], $transactionRow);
        }.bind(this));
    }
    orderSelection.appendTable = function(container) {
        return $('<table></table>').addClass("table").appendTo(container);
    }
    orderSelection.appendHeaderRow = function(container) {
        $tableHead = this.appendTableHeader(container);
        $tableHeadRow = this.appendTableRow($tableHead);
        this.appendHeadData('Date', $tableHeadRow);
        this.appendHeadData('Source', $tableHeadRow);
        this.appendHeadData('Source Reference', $tableHeadRow);
        this.appendHeadData('Comment', $tableHeadRow);
        this.appendHeadData('Transaction Type', $tableHeadRow);
        this.appendHeadData('Loyalty Points', $tableHeadRow);
        this.appendHeadData('Updated Balance', $tableHeadRow);
    }
    orderSelection.appendTableBody = function(container) {
        return $('<tbody></tbody>').appendTo(container);
    }
    orderSelection.appendTableHeader = function(container) {
        return $('<thead></thead>').appendTo(container);
    }
    orderSelection.appendTableRow = function(container) {
        return $('<tr></tr>').appendTo(container);
    }
    orderSelection.appendTableRowData = function(content, container) {
        if (!content) {
          content = "";
        }
        return $('<td>' + content + '</td>').appendTo(container);
    }
    orderSelection.appendHeadData = function(content, container) {
        return $('<th>' + content + '</th>').appendTo(container);
    }
    orderSelection.appendSourceReference = function(source_type, source_reference, container) {
        this.appendTableRowData(source_type.replace('Spree::', ''), container);
        if (source_type == "Spree::Order") {
            $("<td><a href='/admin/orders/" + source_reference + "/edit'>" + source_reference + "</a></td>").appendTo(container);
        }
        else {
            this.appendTableRowData(source_reference, container);
        }
    }
});