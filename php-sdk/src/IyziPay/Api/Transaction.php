<?php namespace IyziPay\Api;

use IyziPay\Common\IyziPayModel;

/**
 * Class Transaction
 * @property \IyziPay\Api\Amount amount
 *
 */

class Transaction extends IyziPayModel
{

    /**
     * @param \IyziPay\Api\Amount $amount
     *
     * @return $this
     */
    public function setAmount($amount)
    {
        $this->amount = $amount;
        return $this;
    }

    public function getAmount()
    {
        return $this->amount;
    }
}