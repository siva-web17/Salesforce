/**
 * Created by arjun.mohan on 10/12/2017.
 */

public  class AdjustmentLineItem {
    public static void onBeforeInsert(List<SObject> newItems) {
        AdjustmentLineItemHelper.updateAdjustmentLineItemFieldsBeforeInsert(newItems);
    }
}